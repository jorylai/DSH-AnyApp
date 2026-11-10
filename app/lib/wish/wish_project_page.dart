import 'dart:async';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../analytics/anyapp_analytics.dart';
import '../runtime/runtime_state.dart';
import 'wish_account_page.dart';
import '../ui/web/local_web_screen.dart';
import '../ui/web/web_target.dart';
import '../ui/web/web_view_page.dart';
import 'wish_app_runtime.dart';
import 'wish_form.dart';
import 'wish_models.dart';
import 'wish_project.dart';
import 'wish_web_bridge.dart';
import 'wish_capabilities_page.dart';
import 'wish_home.dart';
import 'wish_device.dart';
import 'wish_wall_order.dart';
import 'wish_identity.dart';
import 'wish_launch.dart';
import 'wish_project_menu.dart';
import 'wish_records_page.dart';
import 'wish_versions_page.dart';
import 'wish_jobs_page.dart';
import 'wish_creation_monitor.dart';
import 'wish_creator_session.dart';

class WishProjectPage extends StatefulWidget {
  const WishProjectPage({
    super.key,
    required this.project,
    this.creator = false,
    this.startupError,
    this.onHome,
    this.onReadyChanged,
    this.initialConversation,
  });
  final WishProject project;
  final bool creator;
  final String? startupError, initialConversation;
  final VoidCallback? onHome;
  final ValueChanged<bool>? onReadyChanged;
  @override
  State<WishProjectPage> createState() => _WishProjectPageState();
}

class _WishProjectPageState extends State<WishProjectPage> {
  late WishProject _project = widget.project;
  final _link = DshWebLink();
  DshClient? _client;
  WishWebBridge? _bridge;
  String? _error;
  bool _loading = true;
  late bool _creator = widget.creator;
  late String? _conversationId = widget.initialConversation;
  bool _previewReady = false;
  bool _conversationReady = false, _enteringCreator = false;
  bool _interfaceReady = false, _slow = false;
  Timer? _launchTimer;
  String? _stage;
  WishIdentity _identity = const WishIdentity({});
  String get _title => _identity.name(_project.title);
  late final _life = AppLifecycleListener(onResume: _openedReminder);
  Future<void> _openedReminder() async {
    if (widget.onHome != null) return;
    try {
      final id = await WishDevice.call<String>('takeOpenedProject');
      if (id == null || !mounted) return;
      final destination = await WishDevice.call<String>('takeOpenedDestination');
      if (destination == 'background' && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => WishJobsPage(work: id)));
        return;
      }
      if (id == _project.id) return;
      final projects = await WishProject.local();
      for (final project in projects) {
        if (project.id == id && mounted) {
          await Navigator.of(context)
              .pushReplacement(MaterialPageRoute<void>(builder: (_) => WishProjectPage(project: project)));
          break;
        }
      }
    } catch (_) {}
  }

  late final _container = ProviderScope.containerOf(context, listen: false);
  @override
  void initState() {
    super.initState();
    _life;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        _container
            .read(anyappAnalyticsProvider.notifier)
            .track(AnyappEvent.pageView, page: _creator ? AnyappPage.create : AnyappPage.work);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _life.dispose();
    _launchTimer?.cancel();
    _bridge?.dispose();
    super.dispose();
  }

  void _home() {
    widget.onReadyChanged?.call(!_creator && _interfaceReady && !_loading && _error == null);
    if (widget.onHome != null) {
      widget.onHome!();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _load() async {
    final analytics = _container.read(anyappAnalyticsProvider.notifier);
    final timer = Stopwatch()..start();
    var readyNoted = false;
    widget.onReadyChanged?.call(false);
    setState(() {
      _loading = true;
      _interfaceReady = false;
      _slow = false;
      _conversationReady = false;
      _stage = appL10n.wishPreparingWork;
      _error = widget.startupError;
    });
    try {
      _identity = await WishIdentity.get(_project.id);
      // Opening a work uses its installed code. Updates are an explicit action
      // in version management; an optional bundled update must not gate launch.
      final client = await WishAppRuntime.connect(_container, _project.profile);
      if (!mounted) return;
      setState(() => _stage = appL10n.wishConnectingWork);
      _client = client;
      if (_project.sessionId != null) WishCreationMonitor.watch(_project.id, _project.sessionId!, client);
      await recordWishOpen(_project.id);
      try {
        _project = WishProject(wishMap(await client.rpc.call('wishMobile/preview', {'form': _project.id})));
        _previewReady = true;
      } catch (error) {
        _previewReady = false;
        if (!wishPreviewIsDraft(_project, error)) _error = wishErrorText(error);
      }
      _bridge?.dispose();
      _bridge = WishWebBridge(
        projectId: _project.id,
        origin: Uri.parse(_container.read(localRuntimeProvider).status.baseUrl!),
        client: client,
        context: () => context,
        publish: _publish,
        metadataChanged: () async {
          final value = await WishIdentity.get(_project.id);
          if (mounted) setState(() => _identity = value);
        },
        leave: () async {
          if (_creator) {
            await _backToWork();
          } else if (mounted) {
            _home();
          }
        },
        capabilitiesChanged: _load,
        openAgent: (id) async {
          if (!mounted) return;
          setState(() {
            _conversationId = id;
            _conversationReady = true;
            _creator = true;
          });
        },
      );
      _bridge!.onLoading = () {
        widget.onReadyChanged?.call(false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _interfaceReady = false);
        });
      };
      _bridge!.onReady = () {
        if (mounted) widget.onReadyChanged?.call(!_creator && !_loading && _error == null);
        if (mounted && !_creator && !readyNoted) {
          readyNoted = true;
          analytics.track(
            AnyappEvent.workReady,
            page: AnyappPage.work,
            outcome: AnyappOutcome.success,
            elapsed: timer.elapsed,
          );
        }
        if (mounted) setState(() => _interfaceReady = true);
      };
      if (_creator) {
        // An explicitly selected task conversation keeps its own preset and
        // identity. It must not be rebound as the work's Creator conversation.
        if (_conversationId == null || _conversationId == _project.sessionId) {
          await _prepareCreator();
        }
        _conversationReady = true;
      }
      _stage = appL10n.wishLoadingWork;
      _launchTimer?.cancel();
      _launchTimer = Timer(const Duration(seconds: 25), () {
        if (mounted) setState(() => _slow = true);
      });
    } catch (e) {
      if (!_creator && !readyNoted)
        analytics.track(
          AnyappEvent.workReady,
          page: AnyappPage.work,
          outcome: AnyappOutcome.failure,
          elapsed: timer.elapsed,
        );
      _error = wishErrorText(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DshWebTarget get _previewTarget =>
      DshWebTarget(customPanel: _project.panel ?? _project.id, panelLabel: _project.title);

  Future<void> _prepareCreator() async {
    _project = await ensureWishCreatorSession(_client!, _project);
    _conversationId = _project.sessionId;
    WishCreationMonitor.watch(_project.id, _project.sessionId!, _client!);
  }

  Future<void> _enterCreator() async {
    if (_enteringCreator || _client == null) return;
    _enteringCreator = true;
    try {
      final editing = (await _client!.listSessions()).any((session) => session.running);
      if (_previewReady && !editing) await _client!.rpc.call('wishMobile/releaseCheckpoint', {});
      await _prepareCreator();
      if (mounted) {
        setState(() {
          _conversationReady = true;
          _creator = true;
          _error = null;
        });
      }
    } finally {
      _enteringCreator = false;
    }
  }

  Future<void> _models() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WishAccountPage()));
    if (!mounted) return;
    if (_client == null) {
      await _load();
      return;
    }
    try {
      await WishModels.ready(_client!);
      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    }
  }

  Future<Object?> _publish(Map<String, dynamic> args) async {
    final title = args['title'] is String ? (args['title'] as String).trim() : _project.title;
    final panel = args['panel'] is String ? args['panel'] as String : _project.id;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appL10n.wishPublishTitle),
        content: Text('$title\n\n${appL10n.wishPublishHelp}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishAccept)),
        ],
      ),
    );
    if (accepted != true) return null;
    final result = wishMap(
      await _client!.rpc.call('wishMobile/publish', {'form': _project.id, 'title': title, 'panel': panel}),
    );
    if (mounted) setState(() => _project = WishProject(result));
    return result;
  }

  Future<void> _menu() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: wishSurface,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85),
      builder: (ctx) => WishProjectMenu(
        title: _title,
        creator: _creator,
        published: _project.published,
        onSelected: (value) => Navigator.pop(ctx, value),
      ),
    );
    if (!mounted || action == null) return;
    try {
      switch (action) {
        case 'background':
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => WishJobsPage(work: _project.id)));
        case 'versions':
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => WishVersionsPage(project: _project, client: _client!),
            ),
          );
          if (changed == true && mounted) await _load();
        case 'records':
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => WishRecordsPage(
                work: _project.id,
                client: _client!,
                openTask: () async {
                  final id = await _bridge?.agent.session;
                  if (id != null && mounted) {
                    setState(() {
                      _conversationId = id;
                      _conversationReady = true;
                      _creator = true;
                    });
                  }
                },
              ),
            ),
          );
        case 'settings':
          final opened = await _bridge?.openSettings() ?? false;
          if (!opened && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appL10n.wishSettingsNotRegistered)));
          }
        case 'identity':
          await Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => WishIdentityPage(project: _project)));
          _identity = await WishIdentity.get(_project.id);
          if (mounted) setState(() {});
        case 'wall':
          _home();
        case 'creator':
          await _enterCreator();
        case 'preview':
          _project = WishProject(wishMap(await _client!.rpc.call('wishMobile/preview', {'form': _project.id})));
          if (!mounted) return;
          setState(() {
            _previewReady = true;
            _creator = false;
            _error = null;
          });

        case 'publish':
          if (_project.published) {
            final accepted = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(appL10n.wishUnpublish),
                content: Text(appL10n.wishUnpublishHelp),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishUnpublish)),
                ],
              ),
            );
            if (accepted == true) {
              final project = WishProject(
                wishMap(await _client!.rpc.call('wishMobile/unpublish', {'form': _project.id})),
              );
              if (mounted) setState(() => _project = project);
            }
          } else
            await _publish({});
        case 'permissions':
          await Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => WishCapabilitiesPage(projectId: _project.id)));
          if (mounted) await _load(); // phone enable may have restarted the local engine.
        case 'models':
          await _models();
        case 'task':
          final id = await _bridge?.agent.session;
          if (!mounted) return;
          if (id == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appL10n.wishNoTask)));
            return;
          }
          setState(() {
            _conversationId = id;
            _conversationReady = true;
            _creator = true;
          });
      }
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    }
  }

  Future<void> _backToWork() async {
    try {
      _project = WishProject(wishMap(await _client!.rpc.call('wishMobile/preview', {'form': _project.id})));
      _previewReady = true;
    } catch (error) {
      _previewReady = false;
      _error = wishPreviewIsDraft(_project, error) ? null : wishErrorText(error);
    }
    if (!mounted) return;
    setState(() => _creator = false);
  }

  bool get _documentUnavailable => _loading || _client == null || (_creator && !_conversationReady);

  Future<void> _backBeforeDocument() async {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    } else {
      _home();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    // Cached works share the home's route. Until the WebView can own back,
    // leaving a loading/error screen must still return to that home.
    canPop: !_documentUnavailable,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _documentUnavailable) unawaited(_backBeforeDocument());
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: wishBg,
      body: Stack(
        children: [
          Column(
            children: [
              if (_creator)
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: appL10n.wishBackWork,
                          onPressed: _backToWork,
                          icon: const Icon(Icons.arrow_back, color: wishText),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _conversationId != null && _conversationId != _project.sessionId
                                    ? appL10n.wishTaskConversation
                                    : appL10n.wishCreatorHeader,
                                style: const TextStyle(color: wishText, fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: wishText3, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: appL10n.wishWorkMenu,
                          onPressed: _loading ? null : _menu,
                          icon: const Icon(Icons.more_horiz, color: wishText),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_error != null && (!_creator || _conversationReady) && _previewReady)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 58),
                    child: ListTile(
                      title: Text(_error!, maxLines: 3),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _error = null),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _loading
                    ? WishLaunch(title: _title, icon: _identity.icon, stage: _stage ?? appL10n.wishPreparingWork)
                    : _client == null || (_creator && !_conversationReady)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_error != null) Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              TextButton(onPressed: _load, child: Text(appL10n.wishRetry)),
                            ],
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          // Replace the document when entering a conversation: plugin overlays, portals
                          // and global CSS must not survive over the Creator composer. The engine and
                          // session stay alive; only the presentation changes.
                          Offstage(
                            offstage: !_creator && !_previewReady,
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: _creator,
                              child: LocalWebScreen(
                                key: ValueKey((_creator, _creator ? _conversationId ?? _project.sessionId : null)),
                                link: _link,
                                wishBridge: _bridge,
                                workOnly: !_creator,
                                target: _creator
                                    ? DshWebTarget(sessionId: _conversationId ?? _project.sessionId)
                                    : _previewTarget,
                              ),
                            ),
                          ),
                          if (!_creator && _previewReady && !_interfaceReady)
                            WishLaunch(
                              title: _title,
                              icon: _identity.icon,
                              stage: _stage ?? appL10n.wishLoadingWork,
                              retry: _slow ? _load : null,
                            ),
                          if (!_creator && !_previewReady)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_error == null ? Icons.auto_awesome_outlined : Icons.error_outline, size: 40),
                                    const SizedBox(height: 20),
                                    Text(_error ?? appL10n.wishDraftPreview, style: const TextStyle(fontSize: 22)),
                                    const SizedBox(height: 12),
                                    if (_error == null)
                                      Text(appL10n.wishDraftPreviewHelp)
                                    else
                                      TextButton(onPressed: _load, child: Text(appL10n.wishRetry)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
          if (!_creator)
            Positioned(
              right: MediaQuery.paddingOf(context).right + 12,
              top: MediaQuery.paddingOf(context).top + 10,
              child: Material(
                color: wishSurfaceAlt.withValues(alpha: .94),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x26FFFFFF)),
                ),
                child: IconButton(
                  tooltip: appL10n.wishWorkMenu,
                  onPressed: _loading ? null : _menu,
                  icon: const Icon(Icons.more_horiz, color: wishText),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
