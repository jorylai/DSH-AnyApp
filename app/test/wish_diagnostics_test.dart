import 'package:dsh_app/wish/wish_diagnostics_page.dart';
import 'package:dsh_client/dsh_client.dart';
import 'package:flutter_test/flutter_test.dart';

SettingsDescription _settings(
  WishDiagnosticKind kind,
  Object value, {
  bool writable = true,
  bool supported = true,
  bool disabled = false,
  bool locked = false,
}) {
  final node = kind == WishDiagnosticKind.sessionLog
      ? {
          'type': 'boolean',
          'meta': {'disabled': disabled},
        }
      : {
          'type': 'union',
          'meta': {'disabled': disabled},
          'list': [
            {'type': 'const', 'value': 'FEEDBACK_ONLY'},
            {'type': 'const', 'value': 'DISABLED'},
          ],
        };
  return SettingsDescription(
    writable: writable,
    namespaces: {
      kind.namespace: SettingsNamespaceView(
        ns: kind.namespace,
        revision: 27,
        schema: SchemaNode.fromJson({
          'type': 'object',
          'dict': {if (supported) kind.field: node},
        }),
        value: {kind.field: value, 'keepOtherSetting': 123},
        base: {kind.field: locked ? !(value as bool) : value},
        writable: writable,
      ),
    },
  );
}

void main() {
  test('missing or unknown actual settings never appear disabled or editable', () {
    final missing = wishDiagnosticControl(const SettingsDescription(namespaces: {}), WishDiagnosticKind.sessionLog);
    expect(missing.provided, isFalse);
    expect(missing.enabled, isNull);
    expect(missing.canChange, isFalse);
    final unknown = wishDiagnosticControl(
      _settings(WishDiagnosticKind.feedback, 'AUTOMATIC'),
      WishDiagnosticKind.feedback,
    );
    expect(unknown.enabled, isNull);
    expect(unknown.canChange, isFalse);
    expect(
      wishDiagnosticEdit(_settings(WishDiagnosticKind.feedback, 'AUTOMATIC'), WishDiagnosticKind.feedback, false),
      isNull,
    );
  });

  test('writes target exactly one supplied field using the current revision', () {
    for (final kind in WishDiagnosticKind.values) {
      final description = _settings(kind, kind.requestedValue(true));
      final edit = wishDiagnosticEdit(description, kind, false)!;
      expect(edit.namespace, kind.namespace);
      expect(edit.revision, 27);
      expect(edit.ops.single.toJson(), {
        'op': 'set',
        'path': [kind.field],
        'value': kind.requestedValue(false),
      });
      expect(description.namespaces[kind.namespace]!.value['keepOtherSetting'], 123);
    }
  });

  test('read-only, locked, disabled and unexposed schema fields cannot be changed', () {
    const kind = WishDiagnosticKind.sessionLog;
    for (final description in [
      _settings(kind, true, writable: false),
      _settings(kind, true, disabled: true),
      _settings(kind, true, supported: false),
      _settings(kind, true, locked: true),
    ]) {
      final control = wishDiagnosticControl(description, kind);
      expect(control.enabled, isTrue);
      expect(control.canChange, isFalse);
      expect(wishDiagnosticEdit(description, kind, false), isNull);
    }
  });

  test('feedback-only and disabled are the only supported feedback states', () {
    expect(
      wishDiagnosticControl(
        _settings(WishDiagnosticKind.feedback, 'FEEDBACK_ONLY'),
        WishDiagnosticKind.feedback,
      ).enabled,
      isTrue,
    );
    expect(
      wishDiagnosticControl(_settings(WishDiagnosticKind.feedback, 'DISABLED'), WishDiagnosticKind.feedback).enabled,
      isFalse,
    );
    expect(WishDiagnosticKind.feedback.requestedValue(true), 'FEEDBACK_ONLY');
    expect(WishDiagnosticKind.feedback.requestedValue(false), 'DISABLED');
  });
}
