import 'dart:async';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/anyapp_analytics.dart';
import '../l10n/l10n.dart';
import '../state/account_state.dart';
import '../state/connection_state.dart';
import '../state/engine_control.dart';
import '../state/models_state.dart' show defaultModelSettingsNs;
import '../state/model_defaults_state.dart' show defaultModelOps;
import 'wish_models.dart';
import 'wish_palette.dart';
import 'wish_ui.dart';

class WishAccountPage extends ConsumerStatefulWidget {
  const WishAccountPage({super.key, this.onboarding = false});
  final bool onboarding;
  @override
  ConsumerState<WishAccountPage> createState() => _WishAccountState();
}

class _WishAccountState extends ConsumerState<WishAccountPage> {
  ModelCatalog? _catalog;
  DshClient? _client;
  String? _selected, _error;
  bool _busy = false, _loading = false, _ownsSignIn = false, _reloadAfter = false;
  late final AccountController _account;
  late final AnyappAnalytics _analytics;
  late final _life = AppLifecycleListener(onResume: _resume);
  @override
  void initState() {
    super.initState();
    _account = ref.read(accountProvider.notifier);
    _analytics = ref.read(anyappAnalyticsProvider.notifier);
    _life;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _analytics.track(AnyappEvent.pageView, page: AnyappPage.login);
      _load();
    });
  }

  @override
  void dispose() {
    _life.dispose();
    // Leaving the sign-in page cancels only an attempt this page initiated.
    // The Host settles a committing authorization before cancellation.
    if (_ownsSignIn) unawaited(_account.cancel().catchError((Object _) {}));
    super.dispose();
  }

  Future<void> _resume() async {
    if (!mounted) return;
    _account.noteAppResumed();
    await _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    if (_loading) {
      _reloadAfter = true;
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _client = null;
      _catalog = null;
      _selected = null;
    });
    try {
      await EngineControl.ensureStarted(ProviderScope.containerOf(context, listen: false));
      if (!mounted) return;
      // OAuth belongs to the on-device engine. Never use an active remote
      // connection's catalog or model settings on this account screen.
      final local = ref.read(localConnectionProvider);
      if (local.isLoading || local.hasError) return;
      final connection = local.value;
      if (connection == null || !connection.isLocal) return;
      final client = connection.client;
      _client = client;
      String? selected;
      try {
        final route = await WishModels.ready(client);
        selected = '${route['provider']}|${route['model']}';
      } catch (_) {
        /* A catalog may exist before an account/model is configured. */
      }
      final catalog = await client.listModels();
      if (!mounted || !identical(ref.read(localConnectionProvider).value?.client, client)) return;
      setState(() {
        _catalog = catalog;
        _selected = selected;
      });
      await _account.refreshProfile();
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.anyAccountLoadFailed);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (_reloadAfter) {
          _reloadAfter = false;
          unawaited(_load());
        }
      }
    }
  }

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    _ownsSignIn = true;
    final clock = Stopwatch()..start();
    _analytics.track(AnyappEvent.loginStart, page: AnyappPage.login, outcome: AnyappOutcome.start);
    try {
      final result = await _account.signIn(brightness: Brightness.dark);
      _ownsSignIn = false;
      _analytics.track(
        AnyappEvent.loginResult,
        page: AnyappPage.login,
        elapsed: clock.elapsed,
        outcome: switch (result) {
          SignInResult.success => AnyappOutcome.success,
          SignInResult.cancelled => AnyappOutcome.cancelled,
          SignInResult.failed => AnyappOutcome.failure,
        },
      );
      if (mounted) await _load();
    } catch (_) {
      _ownsSignIn = false;
      _analytics.track(
        AnyappEvent.loginResult,
        page: AnyappPage.login,
        outcome: AnyappOutcome.failure,
        elapsed: clock.elapsed,
      );
      if (mounted) setState(() => _error = appL10n.stateSignInIncompleteRetry);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choose(String? key) async {
    if (key == null || _client == null || _busy) return;
    final client = _client!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final models = [for (final g in _catalog?.groups ?? <ProviderGroup>[]) ...g.models];
      final model = models.where((m) => '${m.provider}|${m.id}' == key).firstOrNull;
      if (model == null) throw StateError('model-selection-unavailable');
      if (!identical(ref.read(localConnectionProvider).value?.client, client)) throw StateError('runtime-disconnected');
      final section = await client.settingsSection(defaultModelSettingsNs);
      if (section == null) throw StateError('model-settings-unavailable');
      await client.mutateSettings(
        defaultModelSettingsNs,
        defaultModelOps(ModelSelection(provider: model.provider, model: model.id)),
        expectedRevision: section.revision,
      );
      final route = await WishModels.ready(client);
      if ('${route['provider']}|${route['model']}' != key) throw StateError('model-selection-not-applied');
      if (mounted && identical(ref.read(localConnectionProvider).value?.client, client)) {
        setState(() => _selected = key);
      }
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.anyAccountSelectionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _browser({bool external = false}) async {
    try {
      await _account.reopenBrowser(external: external);
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.anyAccountBrowserFailed);
    }
  }

  Future<void> _cancel() async {
    try {
      await _account.cancel();
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.stateSignInIncompleteRetry);
    }
  }

  Future<void> _usage(String raw) async {
    try {
      final uri = Uri.tryParse(raw);
      if (uri == null ||
          uri.scheme != 'https' ||
          !uri.hasAuthority ||
          uri.userInfo.isNotEmpty ||
          !await ref.read(accountBrowserProvider).open(uri)) {
        if (mounted) setState(() => _error = appL10n.anyAccountBrowserFailed);
      }
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.anyAccountBrowserFailed);
    }
  }

  Future<void> _signOut() async {
    if (_busy) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(appL10n.wishSignOut),
        content: Text(appL10n.wishSignOutHelp),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(appL10n.wishKeep)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(appL10n.wishSignOut)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _account.signOut();
      if (mounted) await _load();
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.anyAccountSignOutFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _status(AccountState state) {
    if (state.signingIn) {
      return switch (state.stage) {
        SignInStage.preparing => appL10n.engineAccountPreparingSignIn,
        SignInStage.waitingBrowser => appL10n.engineAccountFinishInBrowser,
        SignInStage.finishing => appL10n.engineAccountFinishingSignIn,
        null => appL10n.wishSigningIn,
      };
    }
    if (state.signedIn) return appL10n.wishSignedIn;
    if (state.phase == AccountPhase.unsupported) return appL10n.engineAccountUnsupported;
    return state.phase == AccountPhase.unknown ? appL10n.wishAuthUnknown : appL10n.wishSignedOut;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountState>(accountProvider, (previous, next) {
      if ((previous?.phase != next.phase || previous?.connected != next.connected) && !next.signingIn) _load();
    });
    ref.listen<AsyncValue<HostConnection?>>(localConnectionProvider, (previous, next) {
      if (!identical(previous?.value?.client, next.value?.client) ||
          previous?.isLoading != next.isLoading ||
          previous?.hasError != next.hasError) {
        _load();
      }
    });
    final state = ref.watch(accountProvider);
    final destination = accountAuthorizationDestination(state.authorizeUrl);
    final models = [for (final g in _catalog?.groups ?? <ProviderGroup>[]) ...g.models];
    return WishPage(
      title: appL10n.wishSettingsAccount,
      actions: [
        IconButton(tooltip: appL10n.wishRefresh, onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
      ],
      children: [
        Text(appL10n.anyAccountSecurityHelp, style: const TextStyle(color: wishText2, height: 1.6)),
        const SizedBox(height: 20),
        WishCard(
          title: state.profile?.displayName ?? (state.signedIn ? appL10n.wishSignedIn : appL10n.wishSettingsAccount),
          help: _status(state),
          children: [
            if (!state.signedIn && !state.signingIn && state.phase != AccountPhase.unsupported)
              Padding(
                padding: const EdgeInsets.all(18),
                child: FilledButton.icon(
                  onPressed: _busy || _loading ? null : _signIn,
                  icon: const Icon(Icons.open_in_browser),
                  label: Text(appL10n.wishAccountSignIn),
                ),
              ),
            if (state.signingIn && state.browserHint != BrowserHint.none)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: Text(
                  state.browserHint == BrowserHint.notOpened
                      ? appL10n.anyAccountBrowserMissingHelp
                      : appL10n.anyAccountReturnedHelp,
                  style: const TextStyle(color: wishWarm, height: 1.6),
                ),
              ),
            if (state.signingIn && state.authorizeUrl != null) ...[
              WishRow(
                title: appL10n.engineAccountReopenSignIn,
                help: destination,
                icon: Icons.open_in_browser,
                onTap: _browser,
              ),
              WishRow(
                title: appL10n.wishAuthExternal,
                help: appL10n.wishAuthBrowserHelp,
                icon: Icons.open_in_new,
                onTap: () => _browser(external: true),
              ),
            ],
            if (state.signingIn) WishRow(title: appL10n.engineAccountCancelSignIn, onTap: _cancel),
            if (state.signedIn && state.profileFailed)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Text(
                  appL10n.anyAccountProfileUnavailable,
                  style: const TextStyle(color: wishText3, height: 1.5),
                ),
              ),
            if (state.signedIn)
              WishRow(
                title: appL10n.wishAccountUsage,
                icon: Icons.open_in_new,
                onTap: state.links == null || _busy ? null : () => _usage(state.links!.usageUrl),
              ),
            if (state.signedIn) WishRow(title: appL10n.wishSignOut, icon: Icons.logout, onTap: _busy ? null : _signOut),
          ],
        ),
        if (_busy || _loading) const Padding(padding: EdgeInsets.only(bottom: 16), child: LinearProgressIndicator()),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(_error!, style: const TextStyle(color: wishWarm, height: 1.5)),
          ),
        if (state.failure != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${state.failure!.title}\n${state.failure!.message}',
              style: const TextStyle(color: wishWarm, height: 1.5),
            ),
          ),
        WishCard(
          title: appL10n.wishAccountModel,
          help: appL10n.wishModelSelectionHelp,
          children: [
            if (models.isEmpty)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  _loading ? appL10n.anyAccountModelLoading : appL10n.anyAccountModelEmpty,
                  style: const TextStyle(color: wishText2, height: 1.6),
                ),
              ),
            if (models.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(18),
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_selected),
                  initialValue: models.any((m) => '${m.provider}|${m.id}' == _selected) ? _selected : null,
                  isExpanded: true,
                  items: [
                    for (final m in models)
                      DropdownMenuItem(
                        value: '${m.provider}|${m.id}',
                        child: Text(m.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: _busy || _loading ? null : _choose,
                ),
              ),
          ],
        ),
        Text(appL10n.anyAccountReadyHelp, style: const TextStyle(color: wishText2, height: 1.5)),
        if (widget.onboarding) ...[
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.signingIn || _busy ? null : () => Navigator.of(context).maybePop(),
            child: Text(state.signedIn ? appL10n.anyAccountContinue : appL10n.anyAccountReturnOnboarding),
          ),
        ],
      ],
    );
  }
}
