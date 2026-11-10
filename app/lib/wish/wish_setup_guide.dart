import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../analytics/anyapp_analytics.dart';
import '../l10n/l10n.dart';
import '../state/phone_state.dart';
import 'wish_device.dart';
import 'wish_floating_entry_switch.dart';
import 'wish_permissions.dart';
import 'wish_phone_brand_guide.dart';
import 'wish_phone_setup.dart';
import 'wish_palette.dart';
import 'wish_motion.dart';
import 'wish_ui.dart';

/// Shared first-run and settings guide. Visiting a settings page is never a grant.
class WishSetupGuidePage extends ConsumerStatefulWidget {
  const WishSetupGuidePage({
    super.key,
    this.onboarding = false,
    this.onDone,
    this.onSkip,
    this.initialTopic,
    this.embedded = false,
  });
  final bool onboarding;

  /// In-place permission help, with no page or back-stack of its own.
  final bool embedded;
  final VoidCallback? onDone, onSkip;
  final String? initialTopic;
  @override
  ConsumerState<WishSetupGuidePage> createState() => _WishSetupGuidePageState();
}

class _WishSetupGuidePageState extends ConsumerState<WishSetupGuidePage> {
  Map<String, dynamic> _info = {};
  final Set<String> _visited = {};
  String? _override, _active;
  String _group = 'basic';
  bool _checking = true, _busy = false, _showMore = false;
  String? _error, _notice;
  int _revision = 0;
  late final _life = AppLifecycleListener(onResume: _refresh);
  WishPhoneBrand get _brand => WishPhoneBrandGuide.detect(
    manufacturer: _info['manufacturer'] as String?,
    brand: _info['brand'] as String?,
    override: _override,
  );
  int? get _sdk => (_info['sdkInt'] as num?)?.toInt();

  @override
  void initState() {
    super.initState();
    _life;
    _active = widget.initialTopic;
    if (['accessibility', 'phoneEngine', 'restrictedSettings', 'overlay'].contains(_active)) _group = 'phone';
    if (['developerOptions', 'usbDebugging', 'wirelessDebugging'].contains(_active)) _group = 'advanced';
    _load();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _override = p.getString('anyapp.setup.brand.v1');
        _visited.addAll(p.getStringList('anyapp.setup.visited.v1') ?? []);
        if (widget.onboarding && widget.initialTopic == null) _active = p.getString('anyapp.setup.resume.v1');
        if (['accessibility', 'phoneEngine', 'restrictedSettings', 'overlay'].contains(_active)) _group = 'phone';
        if (['developerOptions', 'usbDebugging', 'wirelessDebugging'].contains(_active)) _group = 'advanced';
      });
    } catch (_) {
      /* The live system check still works without saved preferences. */
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    final revision = ++_revision;
    if (mounted) setState(() => _checking = true);
    try {
      final value = await WishDevice.call<Map>('setup.info');
      if (value == null) throw StateError('setup-info-unavailable');
      if (mounted && revision == _revision) {
        setState(() {
          _info = value.cast<String, dynamic>();
          _checking = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() {
          _info = {
            for (final key in ['manufacturer', 'brand', 'model', 'sdkInt', 'release', 'appLabel'])
              if (_info.containsKey(key)) key: _info[key],
          };
          _checking = false;
          _error = appL10n.phoneSetupReadFailed;
        });
      }
    }
  }

  Map _map(String key) => _info[key] is Map ? _info[key] as Map : {};
  bool? _value(Map source, String key) => source[key] is bool ? source[key] as bool : null;
  bool? _state(String id) {
    if (_checking) return null;
    final permissions = _map('permissions');
    switch (id) {
      case 'phoneEngine':
        final p = _map('phone');
        if (p['enabled'] == false) return false;
        return p['enabled'] == true && p['bridgeListening'] == true ? true : null;
      case 'accessibility':
        final a = _map('accessibility');
        if (a['serviceConnected'] == true) return true;
        return a['enabled'] == false ? false : null;
      case 'notifications':
        return _value(_map('notifications'), 'enabled');
      case 'notificationAccess':
        return _value(_map('notifications'), 'listenerEnabled');
      case 'calendar':
        if (permissions['calendarRead'] == true && permissions['calendarWrite'] == true) return true;
        return permissions['calendarRead'] == false || permissions['calendarWrite'] == false ? false : null;
      case 'developerOptions':
        return _value(_info, 'developerOptions');
      case 'usbDebugging':
        return _value(_info, 'usbDebugging');
      case 'wirelessDebugging':
        return _value(_info, 'wirelessDebugging');
      default:
        return _value(permissions, id);
    }
  }

  String _status(String id) {
    if (_checking) return appL10n.phoneSetupChecking;
    if (id == 'restrictedSettings') return appL10n.phoneSetupIfBlocked;
    if (['files', 'screenCapture', 'entries', 'speech'].contains(id)) return appL10n.phoneSetupWhenUsed;
    if (id == 'wirelessDebugging' && _sdk != null && _sdk! < 30) return appL10n.phoneSetupUnsupported;
    if (id == 'phoneEngine' && _map('phone')['enabled'] == true && _map('phone')['bridgeListening'] != true) {
      return appL10n.phoneSetupEngineWaiting;
    }
    if (id == 'calendar' &&
        (_map('permissions')['calendarRead'] == true) != (_map('permissions')['calendarWrite'] == true)) {
      return appL10n.phoneSetupPartial;
    }
    if (id == 'accessibility' &&
        _map('accessibility')['enabled'] == true &&
        _map('accessibility')['serviceConnected'] != true) {
      return appL10n.phoneSetupServiceWaiting;
    }
    final value = _state(id);
    if (value == true) return appL10n.phoneSetupOn;
    if (value == false) return appL10n.phoneSetupOff;
    return _visited.contains(id) ? appL10n.phoneSetupVisited : appL10n.phoneSetupUnknown;
  }

  IconData _icon(String id) => switch (id) {
    'camera' => Icons.camera_alt_outlined,
    'microphone' => Icons.mic_none_rounded,
    'notifications' => Icons.notifications_active_outlined,
    'notificationAccess' => Icons.mark_email_read_outlined,
    'phoneEngine' => Icons.smart_toy_outlined,
    'accessibility' => Icons.accessibility_new_rounded,
    'restrictedSettings' => Icons.lock_open_outlined,
    'overlay' => Icons.bubble_chart_outlined,
    'batteryExempt' => Icons.battery_saver_outlined,
    'autostart' => Icons.restart_alt_rounded,
    'background' => Icons.layers_outlined,
    'popup' => Icons.open_in_new_rounded,
    'exact' => Icons.alarm_rounded,
    'calendar' => Icons.event_available_outlined,
    'location' => Icons.location_on_outlined,
    'files' => Icons.folder_open_outlined,
    'screenCapture' => Icons.screenshot_rounded,
    'entries' => Icons.widgets_outlined,
    'speech' => Icons.record_voice_over_outlined,
    _ => Icons.code_rounded,
  };

  String _title(String id) => switch (id) {
    'camera' => appL10n.wishCamera,
    'microphone' => appL10n.wishMicrophone,
    'notifications' => appL10n.anySetupNotificationsTitle,
    'notificationAccess' => appL10n.wishNotificationReading,
    'phoneEngine' => appL10n.anySetupEngineTitle,
    'accessibility' => appL10n.anySetupA11yTitle,
    'restrictedSettings' => appL10n.phoneSetupRestrictedTitle,
    'overlay' => appL10n.anySetupOverlayTitle,
    'batteryExempt' => appL10n.wishBattery,
    'autostart' => appL10n.wishAutoStart,
    'background' => appL10n.wishBackgroundSetup,
    'popup' => appL10n.wishBackgroundPopup,
    'exact' => appL10n.wishExactSetup,
    'calendar' => appL10n.wishCalendar,
    'location' => appL10n.wishLocation,
    'files' => appL10n.wishFiles,
    'screenCapture' => appL10n.phoneSetupCaptureTitle,
    'entries' => appL10n.phoneSetupEntriesTitle,
    'speech' => appL10n.wishSpeech,
    'developerOptions' => appL10n.phoneSetupDeveloperTitle,
    'usbDebugging' => appL10n.phoneSetupUsbTitle,
    _ => appL10n.phoneSetupWirelessTitle,
  };

  String _help(String id) => switch (id) {
    'camera' => appL10n.anySetupCameraHelp,
    'microphone' => appL10n.anySetupMicHelp,
    'notifications' => appL10n.anySetupNotificationsHelp,
    'notificationAccess' => appL10n.anySetupListenerHelp,
    'phoneEngine' => appL10n.anySetupEngineHelp,
    'accessibility' => appL10n.anySetupA11yHelp,
    'restrictedSettings' => appL10n.anySetupRestrictedHelp,
    'overlay' => appL10n.anySetupOverlayHelp,
    'batteryExempt' => appL10n.anySetupBatteryHelp,
    'autostart' => appL10n.anySetupAutostartHelp,
    'background' => appL10n.anySetupBackgroundHelp,
    'popup' => appL10n.anySetupPopupHelp,
    'exact' => appL10n.anySetupExactHelp,
    'calendar' => appL10n.anySetupCalendarHelp,
    'location' => appL10n.anySetupLocationHelp,
    'files' => appL10n.anySetupFilesHelp,
    'screenCapture' => appL10n.anySetupCaptureHelp,
    'entries' => appL10n.anySetupEntriesHelp,
    'speech' => appL10n.anySetupSpeechHelp,
    _ => appL10n.phoneSetupDeveloperHelp,
  };

  String _summary(String id) => switch (id) {
    'notifications' => appL10n.anySetupReminderSummary,
    'accessibility' => appL10n.anySetupA11ySummary,
    'overlay' => appL10n.anySetupOverlaySummary,
    _ => _help(id),
  };

  List<String> get _visible => switch (_group) {
    'phone' => [
      'phoneEngine',
      'accessibility',
      'restrictedSettings',
      'overlay',
      'notifications',
      'background',
      'popup',
    ],
    'remind' => ['notifications', 'exact', 'batteryExempt', 'autostart', 'background', 'popup'],
    'life' => [
      'calendar',
      'location',
      'notificationAccess',
      'microphone',
      'speech',
      'files',
      'screenCapture',
      'entries',
    ],
    'advanced' => ['developerOptions', 'usbDebugging', 'wirelessDebugging'],
    _ =>
      widget.onboarding
          ? ['notifications', 'accessibility', 'overlay']
          : ['camera', 'microphone', 'notifications', 'files'],
  };

  WishPhoneGuideTopic? _topic(String id) => switch (id) {
    'accessibility' => WishPhoneGuideTopic.accessibility,
    'restrictedSettings' => WishPhoneGuideTopic.restrictedSettings,
    'overlay' => WishPhoneGuideTopic.overlay,
    'batteryExempt' || 'background' => WishPhoneGuideTopic.background,
    'autostart' => WishPhoneGuideTopic.autostart,
    'popup' => WishPhoneGuideTopic.popup,
    'notifications' => WishPhoneGuideTopic.notifications,
    'exact' => WishPhoneGuideTopic.exactAlarms,
    'developerOptions' => WishPhoneGuideTopic.developerOptions,
    'usbDebugging' => WishPhoneGuideTopic.usbDebugging,
    'wirelessDebugging' => WishPhoneGuideTopic.wirelessDebugging,
    _ => null,
  };

  List<String> _steps(String id) {
    final topic = _topic(id);
    if (topic != null) return WishPhoneBrandGuide.steps(_brand, topic, appL10n, sdk: _sdk);
    return switch (id) {
      'phoneEngine' => [appL10n.anySetupEngineStep, appL10n.anySetupEngineNext, appL10n.phoneSetupPerWork],
      'notificationAccess' => [
        appL10n.phoneSetupListenerStep,
        appL10n.phoneSetupListenerApps,
        appL10n.phoneSetupPerWork,
      ],
      'calendar' ||
      'location' ||
      'camera' ||
      'microphone' => [appL10n.phoneSetupRuntimeStep, appL10n.phoneSetupDeniedStep, appL10n.phoneSetupRevoke],
      'files' => [appL10n.anySetupFilesActionHelp],
      'screenCapture' => [
        appL10n.phoneSetupCaptureStep,
        appL10n.phoneSetupCaptureProtected,
        appL10n.phoneSetupCaptureStop,
      ],
      'entries' => [appL10n.phoneSetupEntriesStep, appL10n.phoneSetupEntriesLauncher],
      'speech' => [appL10n.phoneSetupSpeechStep, appL10n.phoneSetupSpeechFallback],
      _ => [appL10n.phoneSetupManualSearch],
    };
  }

  String _target(String id) => switch (id) {
    'restrictedSettings' => 'appDetails',
    'batteryExempt' => 'battery',
    'developerOptions' => 'developer',
    _ => id,
  };

  Future<void> _chooseBrand() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(appL10n.phoneSetupAutoBrand),
              leading: const Icon(Icons.auto_awesome_outlined),
              onTap: () => Navigator.pop(ctx, 'auto'),
            ),
            for (final brand in WishPhoneBrand.values)
              ListTile(
                title: Text(WishPhoneBrandGuide.label(brand, appL10n)),
                trailing: brand == _brand ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(ctx, brand.id),
              ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _override = result == 'auto' ? null : result);
    try {
      final p = await SharedPreferences.getInstance();
      if (_override == null) {
        await p.remove('anyapp.setup.brand.v1');
      } else {
        await p.setString('anyapp.setup.brand.v1', _override!);
      }
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.phoneSetupSaveFailed);
    }
  }

  Future<void> _open(String id, {String? target}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
      _error = null;
    });
    try {
      if (widget.onboarding) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('anyapp.setup.resume.v1', id);
      }
      if (id == 'accessibility' && target == null) {
        final preferences = await SharedPreferences.getInstance();
        if (preferences.getBool(PhoneController.disclosureKey) != true) {
          if (!mounted) return;
          final accepted = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              scrollable: true,
              title: Text(appL10n.anySetupDisclosureTitle),
              content: Text(appL10n.anySetupDisclosureBody),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.anySetupDisclosureLater)),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(appL10n.anySetupDisclosureContinue),
                ),
              ],
            ),
          );
          if (accepted != true || !mounted) return;
          await ref.read(phoneProvider.notifier).acceptDisclosure();
        }
      }
      if (!mounted) return;
      if (id == 'phoneEngine' && target == null) {
        await Navigator.push<void>(context, MaterialPageRoute(builder: (_) => const WishPhoneSetupPage()));
      } else if (target == null && ['camera', 'microphone', 'calendar', 'location', 'notifications'].contains(id)) {
        switch (id) {
          case 'camera':
            await WishPermissions.requestCamera();
          case 'microphone':
            await WishPermissions.requestMicrophone();
          case 'notifications':
            await WishPermissions.requestNotifications();
          case 'calendar':
            await WishPermissions.request('requestCalendar');
            await WishPermissions.request('requestCalendarWrite');
          case 'location':
            await WishPermissions.request('requestLocation');
        }
      } else {
        final result = await WishDevice.call<Map>('setup.open', args: {'target': target ?? _target(id)});
        if (result?['opened'] != true) throw StateError('settings-unavailable');
        if (mounted) {
          setState(
            () => _notice = result?['resolvedTarget'] == 'overlayList'
                ? appL10n.anySetupOverlayListHelp
                : result?['fallback'] == true
                ? appL10n.phoneSetupFallback
                : appL10n.phoneSetupReturnCheck,
          );
        }
      }
      _visited.add(id);
      try {
        final p = await SharedPreferences.getInstance();
        await p.setStringList('anyapp.setup.visited.v1', _visited.toList());
      } catch (_) {
        /* The actual grant still comes from the system. */
      }
      await _refresh();
      if (widget.onboarding &&
          target == null &&
          ['camera', 'microphone', 'calendar', 'location', 'notifications'].contains(id) &&
          _state(id) != null) {
        ref
            .read(anyappAnalyticsProvider.notifier)
            .track(
              AnyappEvent.permissionResult,
              page: AnyappPage.permissions,
              outcome: _state(id) == true ? AnyappOutcome.success : AnyappOutcome.failure,
            );
      }
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.phoneSetupOpenFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finish(bool skipped) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove('anyapp.setup.resume.v1');
    } catch (_) {
      /* Parent flags own completion; no permission is inferred here. */
    }
    if (mounted) (skipped ? widget.onSkip : widget.onDone)?.call();
  }

  void _view(String id) {
    setState(() {
      _active = id;
      _notice = null;
      _error = null;
    });
  }

  void _completeTopic() {
    final navigator = Navigator.of(context);
    final returnToCaller = !widget.onboarding && widget.initialTopic != null && navigator.canPop();
    setState(() => _active = null);
    if (returnToCaller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) navigator.pop();
      });
    }
  }

  Widget _detail(String id) {
    final isRuntime = ['camera', 'microphone', 'calendar', 'location', 'notifications'].contains(id);
    final noSetting = ['files', 'screenCapture', 'entries', 'speech'].contains(id);
    final advanced = ['developerOptions', 'usbDebugging', 'wirelessDebugging'].contains(id);
    final ready = _state(id) == true;
    final steps = _steps(id);
    final topic = _topic(id);
    final sources = topic == null ? <Uri>[] : WishPhoneBrandGuide.sources(_brand, topic);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _completeTopic,
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(appL10n.phoneSetupBackList),
        ),
        WishCard(
          title: _title(id),
          help: _help(id),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Text(
                _status(id),
                key: const ValueKey('setup-detail-status'),
                style: TextStyle(color: _state(id) == true ? wishGreen : wishText2),
              ),
            ),
            if (advanced)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Text(appL10n.phoneSetupAdvancedOnly, style: const TextStyle(color: wishWarm, height: 1.5)),
              ),
            if (id == 'overlay' || id == 'accessibility')
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Text(
                  appL10n.anySetupInstalledApp(
                    _info['appLabel'] is String ? _info['appLabel'] as String : 'DSH AnyApp',
                  ),
                  key: const ValueKey('setup-installed-app'),
                  style: const TextStyle(color: wishText, fontWeight: FontWeight.w600, height: 1.5),
                ),
              ),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: wishSurfaceAlt),
                      child: Text('${i + 1}', style: const TextStyle(color: wishText)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(steps[i], style: const TextStyle(color: wishText2, height: 1.6)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (id == 'overlay') ...[
          WishFloatingEntrySwitch(requestPermission: () => _open('overlay'), waitForSystemResume: true),
          Text(appL10n.anySetupOverlayAfterGrant, style: const TextStyle(color: wishText2, height: 1.6)),
          const SizedBox(height: 12),
        ],
        if (id == 'accessibility') ...[
          Text(appL10n.anySetupCorrectService, style: const TextStyle(color: wishText2, height: 1.5)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _view('restrictedSettings'),
            icon: const Icon(Icons.help_outline_rounded),
            label: Text(appL10n.phoneSetupBlocked),
          ),
        ],
        if (id == 'accessibility')
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(appL10n.anySetupA11yReassure, style: const TextStyle(color: wishText2, height: 1.6)),
          ),
        if (!noSetting)
          FilledButton.icon(
            key: ValueKey('setup-enable-$id'),
            onPressed: _busy || (id == 'wirelessDebugging' && _sdk != null && _sdk! < 30)
                ? null
                : ready
                ? _completeTopic
                : () => _open(id),
            icon: const Icon(Icons.north_east_rounded),
            label: Text(
              ready
                  ? appL10n.anySetupReadyAction
                  : switch (id) {
                      'accessibility' => appL10n.anySetupA11yAction,
                      'overlay' => appL10n.anySetupOverlayGrantAction,
                      'notifications' => appL10n.anySetupNotificationsAction,
                      'exact' => appL10n.anySetupExactAction,
                      'phoneEngine' => appL10n.anySetupEngineAction,
                      _ => isRuntime ? appL10n.phoneSetupRequest : appL10n.phoneSetupOpenSettings,
                    },
            ),
          ),
        if (isRuntime || id == 'restrictedSettings' || _visited.contains(id)) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : () => _open(id, target: 'appDetails'),
            child: Text(appL10n.phoneSetupAppDetails),
          ),
        ],
        if (isRuntime && _visited.contains(id) && _state(id) != true)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(appL10n.anySetupDenied, style: const TextStyle(color: wishWarm, height: 1.5)),
          ),
        const SizedBox(height: 12),
        Text(appL10n.phoneSetupRevoke, style: const TextStyle(color: wishText3, height: 1.5)),
        if (sources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  if (!await launchUrl(sources.first, mode: LaunchMode.externalApplication)) {
                    throw StateError('not-opened');
                  }
                } catch (_) {
                  if (mounted) setState(() => _error = appL10n.phoneSetupOpenFailed);
                }
              },
              icon: const Icon(Icons.open_in_browser_rounded),
              label: Text(appL10n.phoneSetupOfficialHelp),
            ),
          ),
      ],
    );
  }

  Widget _inlineTopic(String id) => ExpansionTile(
    key: ValueKey('setup-inline-$id'),
    leading: Icon(_icon(id), color: _state(id) == true ? wishGreen : wishText2),
    title: Text(_title(id)),
    subtitle: Text(_status(id), style: TextStyle(color: _state(id) == true ? wishGreen : wishText3)),
    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(_help(id), style: const TextStyle(color: wishText2, height: 1.5)),
      const SizedBox(height: 12),
      FilledButton.icon(
        key: ValueKey('setup-enable-$id'),
        onPressed: _busy ? null : () => _open(id),
        icon: const Icon(Icons.north_east_rounded),
        label: Text(
          _state(id) == true
              ? appL10n.phoneSetupOpenSettings
              : switch (id) {
                  'accessibility' => appL10n.anySetupA11yAction,
                  'overlay' => appL10n.anySetupOverlayGrantAction,
                  'notifications' => appL10n.anySetupNotificationsAction,
                  'exact' => appL10n.anySetupExactAction,
                  _ => appL10n.phoneSetupOpenSettings,
                },
        ),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(_error!, style: const TextStyle(color: wishWarm)),
        ),
      if (_notice != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(_notice!, style: const TextStyle(color: wishText2, height: 1.5)),
        ),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: _chooseBrand,
        icon: const Icon(Icons.tune_rounded, size: 16),
        label: Text(WishPhoneBrandGuide.label(_brand, appL10n)),
      ),
      if (id == 'accessibility' || id == 'overlay')
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            appL10n.anySetupInstalledApp(_info['appLabel'] is String ? _info['appLabel'] as String : 'DSH AnyApp'),
            style: const TextStyle(color: wishText, fontWeight: FontWeight.w600),
          ),
        ),
      for (final (index, step) in _steps(id).indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${index + 1}.', style: const TextStyle(color: wishBlue, height: 1.5)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(step, style: const TextStyle(color: wishText2, height: 1.5)),
              ),
            ],
          ),
        ),
      if (id == 'accessibility')
        ExpansionTile(
          key: const ValueKey('setup-inline-restrictedSettings'),
          tilePadding: EdgeInsets.zero,
          title: Text(appL10n.phoneSetupBlocked),
          children: [
            for (final step in _steps('restrictedSettings'))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(step, style: const TextStyle(color: wishText2, height: 1.5)),
              ),
            OutlinedButton(
              onPressed: _busy ? null : () => _open('restrictedSettings'),
              child: Text(appL10n.phoneSetupAppDetails),
            ),
          ],
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _inlineTopic(widget.initialTopic!);
    final brand = WishPhoneBrandGuide.label(_brand, appL10n);
    final active = _active;
    return PopScope(
      canPop: active == null || (!widget.onboarding && widget.initialTopic != null),
      onPopInvokedWithResult: (popped, result) {
        if (!popped && _active != null) setState(() => _active = null);
      },
      child: Theme(
        data: wishTheme(Theme.of(context)),
        child: Scaffold(
          backgroundColor: wishBg,
          appBar: AppBar(
            title: Text(appL10n.anySetupTitle),
            actions: [
              IconButton(
                tooltip: appL10n.phoneSetupRecheck,
                onPressed: _busy ? null : _refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          bottomNavigationBar: widget.onboarding
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (active == null)
                          FilledButton(
                            key: const ValueKey('setup-finish'),
                            onPressed: _busy ? null : () => _finish(false),
                            child: Text(appL10n.anySetupContinue),
                          ),
                        TextButton(
                          key: const ValueKey('setup-skip'),
                          onPressed: _busy ? null : () => _finish(true),
                          child: Text(appL10n.anySetupLater),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: WishEntrance(
            key: ValueKey('setup-entrance-${active ?? _group}'),
            child: SafeArea(
              child: CustomScrollView(
                key: ValueKey('setup-scroll-${active ?? _group}'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    sliver: SliverList.list(
                      children: [
                        if (active != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text(brand, style: const TextStyle(color: wishText2)),
                              ),
                              TextButton(onPressed: _chooseBrand, child: Text(appL10n.phoneSetupChangeBrand)),
                            ],
                          ),
                        if (active == null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(colors: [Color(0xFF223454), wishSurface]),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.spa_outlined, color: Color(0xFFAFBDFF), size: 28),
                                const SizedBox(height: 14),
                                Text(
                                  appL10n.anySetupHeroTitle,
                                  style: const TextStyle(color: wishText, fontSize: 24, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.onboarding ? appL10n.anySetupHeroBody : appL10n.anySetupSettingsBody,
                                  style: const TextStyle(color: wishText2, height: 1.6),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$brand${_info['release'] is String ? ' · Android ${_info['release']}' : ''}',
                                  style: const TextStyle(color: wishText),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _chooseBrand,
                                    icon: const Icon(Icons.tune_rounded, size: 18),
                                    label: Text(appL10n.phoneSetupChangeBrand),
                                  ),
                                ),
                                Text(
                                  WishPhoneBrandGuide.caveat(_brand, appL10n),
                                  style: const TextStyle(color: wishText3, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (_checking) const LinearProgressIndicator(),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(_error!, style: const TextStyle(color: wishWarm)),
                          ),
                        if (_notice != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(_notice!, style: const TextStyle(color: wishText2, height: 1.5)),
                          ),
                        if (active != null)
                          _detail(active)
                        else ...[
                          if (!widget.onboarding || _showMore)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final item in [
                                  (
                                    'basic',
                                    widget.onboarding ? appL10n.anySetupOnboardingGroup : appL10n.phoneSetupGroupBasic,
                                  ),
                                  ('phone', appL10n.phoneSetupGroupPhone),
                                  ('remind', appL10n.phoneSetupGroupReminder),
                                  ('life', appL10n.phoneSetupGroupLife),
                                  if (!widget.onboarding) ('advanced', appL10n.phoneSetupGroupAdvanced),
                                ])
                                  ChoiceChip(
                                    key: ValueKey('setup-group-${item.$1}'),
                                    label: Text(item.$2),
                                    selected: _group == item.$1,
                                    onSelected: (_) => setState(() => _group = item.$1),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 18),
                          WishCard(
                            children: [
                              for (final id in _visible)
                                WishRow(
                                  key: ValueKey('setup-topic-$id'),
                                  title: _title(id),
                                  help: '${_summary(id)}\n${_status(id)}',
                                  icon: _icon(id),
                                  onTap: () => _view(id),
                                  trailing: Icon(
                                    _state(id) == true ? Icons.check_circle_outline : Icons.chevron_right,
                                    color: _state(id) == true ? wishGreen : wishText3,
                                  ),
                                ),
                            ],
                          ),
                          if (widget.onboarding) ...[
                            TextButton.icon(
                              key: const ValueKey('setup-more'),
                              onPressed: () => setState(() {
                                _showMore = !_showMore;
                                if (!_showMore) _group = 'basic';
                              }),
                              icon: Icon(_showMore ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                              label: Text(_showMore ? appL10n.anySetupLess : appL10n.anySetupMore),
                            ),
                            Text(appL10n.anySetupOptional, style: const TextStyle(color: wishText2, height: 1.6)),
                            const SizedBox(height: 8),
                            Text(appL10n.anySetupLaterHelp, style: const TextStyle(color: wishText3, height: 1.5)),
                          ] else
                            Text(appL10n.phoneSetupPerWork, style: const TextStyle(color: wishText2, height: 1.6)),
                          const SizedBox(height: 12),
                          Text(appL10n.anySetupNoDebug, style: const TextStyle(color: wishText3, height: 1.5)),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
