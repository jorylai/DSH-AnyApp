import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/wish/wish_creation_monitor.dart';

void main() {
  Map<String, dynamic> row(String type, [String? reason]) => {
    'event': {
      'type': type,
      'data': {
        'reason': {'kind': reason},
      },
    },
  };
  test('idle without a completed turn is not a completed creation', () {
    expect(creationPhase({'records': []}), 'interrupted');
    expect(
      creationPhase({
        'records': [row('turn/start')],
      }),
      'running',
    );
  });
  test('a new turn invalidates an older completion', () {
    expect(
      creationPhase({
        'records': [row('turn/end', 'completed'), row('turn/start')],
      }),
      'running',
    );
  });
  test('failure and blocked approvals never become succeeded', () {
    for (final pair in [
      ('completed', 'succeeded'),
      ('error', 'failed'),
      ('aborted', 'stopped'),
      ('blocked', 'awaiting-confirmation'),
    ]) {
      expect(
        creationPhase({
          'records': [row('turn/end', pair.$1)],
        }),
        pair.$2,
      );
    }
  });
}
