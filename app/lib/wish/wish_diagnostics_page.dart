import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../runtime/runtime_state.dart';
import '../state/connection_state.dart';
import '../state/engine_settings_state.dart' show EngineSettings, schemaAt, schemaPathDisabled;
import 'wish_palette.dart';
import 'wish_ui.dart';

enum WishDiagnosticKind {
  sessionLog,
  feedback;

  String get namespace => switch (this) {
    sessionLog => 'session-log-deepseek',
    feedback => 'session-telemetry-otel',
  };
  String get field => this == sessionLog ? 'enabled' : 'mode';
  Object requestedValue(bool enabled) => this == sessionLog ? enabled : (enabled ? 'FEEDBACK_ONLY' : 'DISABLED');
}

class WishDiagnosticControl {
  const WishDiagnosticControl({required this.provided, required this.enabled, required this.canChange});
  final bool provided;
  final bool? enabled;
  final bool canChange;
}

/// Read only values the live Host supplied. Neither a schema default nor a
/// missing namespace is evidence that uploads are enabled or disabled.
WishDiagnosticControl wishDiagnosticControl(SettingsDescription description, WishDiagnosticKind kind) {
  final view = description.namespaces[kind.namespace];
  if (view == null) return const WishDiagnosticControl(provided: false, enabled: null, canChange: false);
  final path = [kind.field];
  final (provided, value) = lookupPath(view.value, path);
  final bool? enabled = switch (kind) {
    WishDiagnosticKind.sessionLog => value is bool ? value : null,
    WishDiagnosticKind.feedback => switch (value) {
      'FEEDBACK_ONLY' => true,
      'DISABLED' => false,
      _ => null,
    },
  };
  final node = schemaAt(view.schema, path)?.effective;
  final schemaSupported = kind == WishDiagnosticKind.sessionLog
      ? node?.type == 'boolean'
      : node?.enumValues?.contains('FEEDBACK_ONLY') == true && node?.enumValues?.contains('DISABLED') == true;
  final settings = EngineSettings(namespaces: {view.ns: view}, writable: description.writable);
  return WishDiagnosticControl(
    provided: provided,
    enabled: enabled,
    canChange:
        provided &&
        enabled != null &&
        schemaSupported &&
        !schemaPathDisabled(view.schema, path) &&
        settings.canWrite(view.ns),
  );
}

class WishDiagnosticEdit {
  const WishDiagnosticEdit(this.namespace, this.revision, this.ops, this.value);
  final String namespace;
  final int revision;
  final List<SettingsOp> ops;
  final Object value;
}

/// One approved live field, on the exact revision that was just read.
WishDiagnosticEdit? wishDiagnosticEdit(SettingsDescription description, WishDiagnosticKind kind, bool enabled) {
  if (!wishDiagnosticControl(description, kind).canChange) return null;
  final value = kind.requestedValue(enabled);
  return WishDiagnosticEdit(kind.namespace, description.namespaces[kind.namespace]!.revision, [
    SettingsOp.set([kind.field], value),
  ], value);
}

class WishModelDiagnosticsPage extends ConsumerStatefulWidget {
  const WishModelDiagnosticsPage({super.key});
  @override
  ConsumerState<WishModelDiagnosticsPage> createState() => _WishModelDiagnosticsState();
}

class _WishModelDiagnosticsState extends ConsumerState<WishModelDiagnosticsPage> {
  SettingsDescription? _description;
  DshClient? _client;
  bool _loading = false, _saving = false, _workScope = false;
  String? _error, _savedNamespace;
  int _epoch = 0;

  @override
  void initState() {
    super.initState();
    ref.listenManual(localConnectionProvider, (_, next) {
      if (_client != null && !identical(next.value?.client, _client) && mounted) {
        _epoch++;
        setState(() {
          _client = null;
          _description = null;
          _loading = _saving = false;
          _savedNamespace = null;
          _error = appL10n.anyDiagnosticsChanged;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  bool _current(DshClient client) {
    final connection = ref.read(localConnectionProvider).value;
    return connection?.isLocal == true && identical(connection?.client, client);
  }

  Future<SettingsDescription> _read(DshClient client) async =>
      SettingsDescription.fromJson(await client.rpc.call('settings/describe'));

  Future<void> _refresh() async {
    if (_loading || _saving) return;
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _error = null;
      _savedNamespace = null;
      _description = null;
      _client = null;
    });
    try {
      final connection = await ref.read(localConnectionProvider.future);
      if (!mounted || epoch != _epoch) return;
      if (connection == null || !connection.isLocal) return;
      final client = connection.client;
      final description = await _read(client);
      if (!mounted || epoch != _epoch) return;
      if (!_current(client)) throw StateError('environment-changed');
      setState(() {
        _client = client;
        _description = description;
        _workScope = ref.read(localRuntimeProvider).status.profile.startsWith('app-local-');
      });
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _error = appL10n.anyDiagnosticsReadFailed);
    } finally {
      if (mounted && epoch == _epoch) setState(() => _loading = false);
    }
  }

  Future<void> _change(WishDiagnosticKind kind, bool enabled) async {
    final client = _client;
    if (client == null || _loading || _saving || !_current(client)) return;
    final epoch = _epoch;
    setState(() {
      _saving = true;
      _error = null;
      _savedNamespace = null;
    });
    try {
      final before = await _read(client);
      if (!mounted || epoch != _epoch || !_current(client)) return;
      final edit = wishDiagnosticEdit(before, kind, enabled);
      if (edit == null) throw StateError('setting-not-editable');
      await client.mutateSettings(edit.namespace, edit.ops, expectedRevision: edit.revision);
      if (!mounted || epoch != _epoch || !_current(client)) return;
      final after = await _read(client);
      if (!mounted || epoch != _epoch || !_current(client)) return;
      setState(() => _description = after);
      final actual = lookupPath(after.namespaces[kind.namespace]?.value, [kind.field]);
      if (!actual.$1 || actual.$2 != edit.value) throw StateError('setting-not-applied');
      setState(() => _savedNamespace = kind.namespace);
    } catch (_) {
      if (mounted && epoch == _epoch) {
        setState(() {
          _description = null;
          _error = appL10n.anyDiagnosticsSaveFailed;
        });
      }
    } finally {
      if (mounted && epoch == _epoch) setState(() => _saving = false);
    }
  }

  String _status(WishDiagnosticKind kind, WishDiagnosticControl control) {
    if (!control.provided) return appL10n.anyDiagnosticsNotProvided;
    if (control.enabled == null) return appL10n.anyDiagnosticsUnknown;
    return switch (kind) {
      WishDiagnosticKind.sessionLog =>
        control.enabled! ? appL10n.anyDiagnosticsEnabled : appL10n.anyDiagnosticsDisabled,
      WishDiagnosticKind.feedback =>
        control.enabled! ? appL10n.anyDiagnosticsFeedbackOnly : appL10n.anyDiagnosticsFeedbackDisabled,
    };
  }

  Widget _control(WishDiagnosticKind kind) {
    final control = wishDiagnosticControl(_description!, kind);
    final log = kind == WishDiagnosticKind.sessionLog;
    final status = _status(kind, control);
    return WishCard(
      title: log ? appL10n.anyDiagnosticsLogTitle : appL10n.anyDiagnosticsFeedbackTitle,
      help: log ? appL10n.anyDiagnosticsLogHelp : appL10n.anyDiagnosticsFeedbackHelp,
      children: [
        WishRow(
          title: status,
          icon: log ? Icons.description_outlined : Icons.rate_review_outlined,
          trailing: control.enabled == null
              ? const Icon(Icons.info_outline, color: wishText3)
              : Semantics(
                  label: log ? appL10n.anyDiagnosticsLogTitle : appL10n.anyDiagnosticsFeedbackTitle,
                  child: Switch.adaptive(
                    value: control.enabled!,
                    onChanged: control.canChange && !_loading && !_saving ? (on) => _change(kind, on) : null,
                  ),
                ),
        ),
        if (!control.provided || !control.canChange)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Text(
              !control.provided ? appL10n.anyDiagnosticsUnservedHelp : appL10n.anyDiagnosticsReadOnly,
              style: const TextStyle(color: wishText3, fontSize: 12, height: 1.5),
            ),
          ),
        if (_savedNamespace == kind.namespace)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Text(appL10n.anyDiagnosticsSaved, style: const TextStyle(color: wishGreen)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.anyDiagnosticsTitle,
    actions: [
      IconButton(
        onPressed: _loading || _saving ? null : _refresh,
        tooltip: appL10n.anyDiagnosticsReload,
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
    children: [
      WishCard(
        title: appL10n.anyDiagnosticsIntro,
        help: appL10n.anyDiagnosticsIntroBody,
        children: [
          WishRow(
            title: _loading
                ? appL10n.anyDiagnosticsReading
                : (_description != null ? appL10n.anyDiagnosticsConnected : appL10n.anyDiagnosticsDisconnected),
            help: _description == null
                ? appL10n.anyDiagnosticsConnectHelp
                : (_workScope ? appL10n.anyDiagnosticsScopeWork : appL10n.anyDiagnosticsScopeDefault),
            icon: Icons.shield_outlined,
          ),
        ],
      ),
      if (_loading || _saving) ...[
        const LinearProgressIndicator(),
        const SizedBox(height: 10),
        Text(
          _saving ? appL10n.anyDiagnosticsSaving : appL10n.anyDiagnosticsReading,
          style: const TextStyle(color: wishText2),
        ),
        const SizedBox(height: 18),
      ],
      if (_error != null) ...[
        Text(_error!, style: const TextStyle(color: wishWarm, height: 1.5)),
        const SizedBox(height: 12),
      ],
      if (_description != null) ...[
        for (final kind in WishDiagnosticKind.values) _control(kind),
        Text(appL10n.anyDiagnosticsScopeHelp, style: const TextStyle(color: wishText3, height: 1.5)),
        const SizedBox(height: 18),
      ],
      WishCard(title: appL10n.anyDiagnosticsAppTitle, help: appL10n.anyDiagnosticsAppHelp, children: const []),
      Text(appL10n.anyDiagnosticsRetention, style: const TextStyle(color: wishText3, fontSize: 12, height: 1.6)),
    ],
  );
}
