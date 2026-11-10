import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../analytics/anyapp_analytics.dart';
import '../runtime/runtime_state.dart';
import '../share_code/guest_fs.dart';
import 'wish_form.dart';
import 'wish_project.dart';
import 'wish_project_page.dart';
import 'wish_surface.dart';
import 'wish_food_ai.dart';
import 'wish_device.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'wish_wall_order.dart';
import 'wish_identity.dart';
import 'wish_actions.dart';
import 'wish_creation_monitor.dart';
import 'wish_jobs_page.dart';

import 'wish_app_runtime.dart';
import 'wish_create.dart';
import 'wish_settings.dart';
import 'wish_library_page.dart';
import 'wish_gallery.dart';
import 'wish_motion.dart';
import 'wish_preset_bootstrap.dart';

export 'wish_palette.dart';

/// 作品墙：dsh-wish 的首页。只展示作品，不做「作品/壳/应用」分类。
class WishHomePage extends StatefulWidget {
  const WishHomePage({super.key});

  @override
  State<WishHomePage> createState() => _WishHomePageState();
}

class _WishHomePageState extends State<WishHomePage> {
  List<WishForm> _forms = [];
  List<WishProject> _projects = [];
  Map<String, String> _metrics = {};
  String? _error;
  bool _opening = false;
  Widget? _cachedWork;
  String? _cachedToken;
  int _workEpoch = 0;
  String? _cachedId;
  bool _workVisible = false, _cachedReady = false;
  WishWallSort _sort = WishWallSort.added;
  Map<String, int> _lastUsed = {};
  Map<String, WishIdentity> _identities = {};
  late final _life = AppLifecycleListener(onResume: _openedReminder);
  Future<void> _openedReminder() async {
    try {
      if (_opening || !mounted || ModalRoute.of(context)?.isCurrent == false) return;
      final id = await WishDevice.call<String>('takeOpenedProject');
      if (id == null) return;
      final destination = await WishDevice.call<String>('takeOpenedDestination');
      if ((await WishPresetBootstrap.hiddenStarterIds()).contains(id)) return;
      if (destination == 'background' && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => WishJobsPage(work: id)));
        return;
      }
      await _reload();
      final index = _projects.indexWhere((p) => p.id == id);
      if (mounted && index >= 0) await _open(index);
    } catch (_) {}
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        ProviderScope.containerOf(
          context,
          listen: false,
        ).read(anyappAnalyticsProvider.notifier).track(AnyappEvent.pageView, page: AnyappPage.home);
    });
    _life;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await WishActions.init(ProviderScope.containerOf(context, listen: false));
      } catch (_) {
        if (mounted) setState(() => _error = appL10n.wishFailure);
      }
    });
    _reload().then((_) => _openedReminder());
  }

  Future<void> _reload() async {
    try {
      final retired = await WishPresetBootstrap.hiddenStarterIds();
      final projects = (await WishProject.local()).where((project) => !retired.contains(project.id)).toList();
      final identities = await WishIdentity.all();
      for (final project in projects) {
        if (!identities.containsKey(project.id)) {
          final value = await WishDevice.call(
            'works.describe',
            work: project.id,
            args: {
              'value': {'title': project.title},
            },
          );
          identities[project.id] = WishIdentity(wishMap(value));
        }
      }
      final prefs = await SharedPreferences.getInstance();
      final recent = <String, int>{};
      for (final key in prefs.getKeys()) {
        if (key.startsWith('wish-wall-used:')) recent[key.substring(15)] = prefs.getInt(key) ?? 0;
      }
      final fs = await GuestFs.local();
      final file = fs?.file('/root/.dsh/wish/catalog.json');
      final list = file != null && await file.exists() ? jsonDecode(await file.readAsString()) as List : const [];
      final forms = list.map((e) => WishForm(wishMap(e))).where((form) => !retired.contains(form.id)).toList();
      final metrics = <String, String>{};
      for (final form in forms) {
        if (!RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(form.id)) continue;
        final statusFile = fs?.file('/root/.dsh/wish/data/${form.id}/status.json');
        if (statusFile != null && await statusFile.exists()) {
          final status = wishMap(jsonDecode(await statusFile.readAsString()));
          final value =
              form.manifest['statusDaily'] == true &&
                  status['date'] != DateTime.now().toIso8601String().substring(0, 10)
              ? 0
              : status['value'];
          if (value != null) metrics[form.id] = '$value ${form.manifest['statusUnit'] ?? ''}'.trim();
        }
      }
      if (mounted)
        setState(() {
          if (retired.contains(_cachedId)) {
            _cachedWork = null;
            _cachedId = _cachedToken = null;
            _cachedReady = _workVisible = false;
            _workEpoch++;
          }
          _forms = forms;
          _sort = prefs.getString('wish-wall-sort') == 'recent' ? WishWallSort.recent : WishWallSort.added;
          _lastUsed = recent;
          _projects = projects;
          _identities = identities;
          _metrics = metrics;
          _error = null;
        });
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.wishFailure);
    }
  }

  Map<String, dynamic> _workIcon(WishProject p) {
    final declared = _identities[p.id]?.icon ?? const <String, dynamic>{};
    if (declared.isNotEmpty) return declared;
    final name = _identities[p.id]?.name(p.title) ?? p.title;
    final style = name.contains('比价') || name.contains('购物')
        ? ('cart', 'indigo')
        : name.contains('番茄') || name.contains('计时')
        ? ('timer', 'amber')
        : name.contains('热量') || name.contains('食')
        ? ('camera', 'mint')
        : name.toLowerCase().contains('trip') || name.contains('行程')
        ? ('trip', 'mint')
        : name.contains('笔记') || name.contains('记录')
        ? ('book', 'violet')
        : ('spark', 'indigo');
    return {'builtin': style.$1, 'palette': style.$2};
  }

  String _description(WishProject p) {
    final declared = _identities[p.id]?.value['description'];
    if (declared is String && declared.trim().isNotEmpty) return declared.trim();
    final name = _identities[p.id]?.name(p.title) ?? p.title;
    if (name.contains('比价') || name.contains('购物')) return appL10n.wishDescShopping;
    if (name.contains('番茄') || name.contains('计时')) return appL10n.wishDescFocus;
    if (name.contains('热量') || name.contains('食')) return appL10n.wishDescFood;
    if (name.toLowerCase().contains('trip') || name.contains('行程')) return appL10n.wishDescTravel;
    if (name.contains('笔记') || name.contains('记录')) return appL10n.wishDescNotes;
    if (name.contains('助')) return appL10n.wishDescAssistant;
    return appL10n.wishDescPersonal;
  }

  List<WishGalleryItem> get _works => [
    for (final p in _projects)
      WishGalleryItem(
        id: p.id,
        title: _identities[p.id]?.name(p.title) ?? p.title,
        description: _description(p),
        status: p.panel != null ? appL10n.wishWorkAvailable : appL10n.wishWorkGrowing,
        icon: _workIcon(p),
        ready: p.panel != null,
      ),
    for (final f in _forms)
      WishGalleryItem(
        id: f.id,
        title: f.name,
        description: '${f.manifest['subtitle'] ?? ''}',
        status: _metrics[f.id] ?? appL10n.wishWorkAvailable,
        ready: true,
        icon: {'builtin': f.manifest['icon'] == 'camera' ? 'camera' : 'spark', 'palette': 'indigo'},
      ),
  ];

  Future<void> _open(int index) async {
    if (_opening) return;
    ProviderScope.containerOf(context, listen: false)
        .read(anyappAnalyticsProvider.notifier)
        .track(AnyappEvent.workOpen, page: AnyappPage.home, outcome: AnyappOutcome.start);
    final openClock = Stopwatch()..start();
    setState(() => _opening = true);
    try {
      final id = index < _projects.length ? _projects[index].id : _forms[index - _projects.length].id;
      final recorded = recordWishOpen(id);
      final formIndex = index - _projects.length;
      if (index < _projects.length) {
        final project = _projects[index];
        final runtime = ProviderScope.containerOf(context, listen: false).read(localRuntimeProvider).status;
        var reused = true;
        if (_cachedId != project.id ||
            !runtime.isRunning ||
            runtime.profile != project.profile ||
            _cachedToken != runtime.token) {
          reused = false;
          _cachedReady = false;
          _cachedId = project.id;
          final epoch = ++_workEpoch;
          _cachedWork = WishProjectPage(
            key: ValueKey((project.id, epoch)),
            onReadyChanged: (ready) {
              if (mounted && _workEpoch == epoch) _cachedReady = ready;
            },
            project: project,
            onHome: () {
              FocusManager.instance.primaryFocus?.unfocus();
              _cachedToken = ProviderScope.containerOf(context, listen: false).read(localRuntimeProvider).status.token;
              if (mounted) setState(() => _workVisible = false);
              _reload();
            },
          );
        }
        setState(() => _workVisible = true);
        if (reused && _cachedReady)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _workVisible && _cachedId == project.id && _cachedReady) {
              ProviderScope.containerOf(context, listen: false)
                  .read(anyappAnalyticsProvider.notifier)
                  .track(
                    AnyappEvent.workReady,
                    page: AnyappPage.work,
                    outcome: AnyappOutcome.success,
                    elapsed: openClock.elapsed,
                  );
            }
          });
      } else {
        await Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => WishSurfacePage(form: _forms[formIndex])));
      }
      await recorded;
      await _reload();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _remove(int index) async {
    if (_opening || index >= _forms.length) return;
    final form = _forms[index];
    final allowed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appL10n.wishRemove),
        content: Text(appL10n.wishRemoveWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishRemoveConfirm)),
        ],
      ),
    );
    if (allowed != true || !mounted) return;
    setState(() => _opening = true);
    try {
      final client = await WishAppRuntime.connect(ProviderScope.containerOf(context, listen: false), 'web');
      await client.rpc.call('appForm/remove', {'form': form.id});
      await FoodVision.clearForForm(form.id);
      await _reload();
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.wishFailure);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _newWish() async {
    setState(() {
      _cachedWork = null;
      _cachedId = null;
      _workVisible = false;
    });
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WishCreatePage()));
    await _reload();
  }

  Future<void> _manage(int index) async {
    if (_opening) return;
    ProviderScope.containerOf(context, listen: false)
        .read(anyappAnalyticsProvider.notifier)
        .track(AnyappEvent.workManage, page: AnyappPage.home, outcome: AnyappOutcome.start);
    if (index < _projects.length) {
      await _manageProject(_projects[index]);
      return;
    }
    index -= _projects.length;
    if (index >= _forms.length) return;
    final form = _forms[index];
    final action = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: AnimationStyle(
        duration: WishMotion.duration(context, WishMotion.route),
        reverseDuration: WishMotion.duration(context, WishMotion.content),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(appL10n.wishCopyEdit),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(appL10n.wishRemove),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'remove') {
      await _remove(index);
    } else if (action == 'edit') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WishCreatePage(sourceId: form.id, initialRequest: '${form.name}：'),
        ),
      );
      await _reload();
    }
  }

  Future<void> _manageProject(WishProject project) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: AnimationStyle(
        duration: WishMotion.duration(context, WishMotion.route),
        reverseDuration: WishMotion.duration(context, WishMotion.content),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(appL10n.wishPreviewPlugin),
              leading: const Icon(Icons.open_in_new_rounded),
              onTap: () => Navigator.pop(ctx, 'open'),
            ),
            ListTile(
              title: Text(appL10n.wishEditConversation),
              leading: const Icon(Icons.edit_outlined),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              title: Text(appL10n.wishIdentity),
              leading: const Icon(Icons.palette_outlined),
              onTap: () => Navigator.pop(ctx, 'identity'),
            ),
            ListTile(
              title: Text(appL10n.wishRemove),
              leading: const Icon(Icons.delete_outline),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'open') {
      await _open(_projects.indexWhere((p) => p.id == project.id));
    } else if (action == 'identity') {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WishIdentityPage(project: project)));
    } else if (action == 'edit') {
      setState(() {
        _cachedWork = null;
        _cachedId = null;
      });
      await Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => WishProjectPage(project: project, creator: true)));
    } else if (action == 'remove') {
      final allowed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(appL10n.wishRemove),
          content: Text(appL10n.wishRemoveWarning),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.wishKeep)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.wishRemoveConfirm)),
          ],
        ),
      );
      if (allowed != true || !mounted) return;
      setState(() => _opening = true);
      try {
        final client = await WishAppRuntime.connect(ProviderScope.containerOf(context, listen: false), 'web');
        await client.rpc.call('wishMobile/remove', {'form': project.id});
        if (_cachedId == project.id) {
          _cachedWork = null;
          _cachedId = null;
        }
        WishCreationMonitor.forget(project.id);
        await WishDevice.call('works.remove', work: project.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('wish-actions:${project.id}');
        await prefs.remove('wish-agent:${project.id}');
      } catch (e) {
        if (mounted) setState(() => _error = wishErrorText(e));
      } finally {
        if (mounted) setState(() => _opening = false);
      }
    }
    await _reload();
  }

  void _openSettings() {
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(anyappAnalyticsProvider.notifier).track(AnyappEvent.pageView, page: AnyappPage.settings);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WishSettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final works = _works;
    final order = wishWallOrder(
      [
        for (final p in _projects) (id: p.id, added: p.createdAt?.millisecondsSinceEpoch ?? 0),
        for (final f in _forms) (id: f.id, added: 0),
      ],
      _sort,
      _lastUsed,
    );
    final home = WishGallery(
      items: [for (final i in order) works[i]],
      sort: _sort,
      onSort: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('wish-wall-sort', value.name);
        if (mounted) setState(() => _sort = value);
      },
      onOpen: (index) => _open(order[index]),
      onManage: (index) => _manage(order[index]),
      onCreate: _newWish,
      onLibrary: () async {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WishLibraryPage()));
        await _reload();
      },
      onSettings: _openSettings,
      busy: _opening,
      error: _error,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(
          offstage: _workVisible,
          child: TickerMode(enabled: !_workVisible, child: home),
        ),
        if (_cachedWork != null)
          Offstage(
            offstage: !_workVisible,
            child: TickerMode(enabled: _workVisible, child: _cachedWork!),
          ),
      ],
    );
  }
}
