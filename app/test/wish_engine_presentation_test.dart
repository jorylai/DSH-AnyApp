import 'package:dsh_app/wish/wish_engine_presentation.dart';
import 'package:dsh_client/dsh_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../packages/dsh_client/test/support/fake_dsh.dart';

void main() {
  late FakeDsh host;
  late DshClient client;
  setUp(() async {
    host = await FakeDsh.start();
    client = await DshClient.connect(
      baseUri: host.baseUri,
      token: FakeDsh.token,
      muxOptions: const MuxOptions(readyTimeout: Duration(seconds: 2)),
    );
  });
  tearDown(() async {
    await client.close();
    await host.close();
  });

  Map<String, Object?> section(Map<String, Object?> values, {int revision = 7}) => {
    'ns': WishEnginePresentation.namespace,
    'value': values,
    'revision': revision,
  };
  void describe(Map<String, Object?>? current, {bool writable = true}) {
    host.handlers['settings/describe'] = (_) => {
      'ok': true,
      'value': {
        'writable': writable,
        'namespaces': [?current],
      },
    };
  }

  test('new work profile saves only the official preview presentation field', () async {
    describe(section({'retainedSetting': 'keep'}));
    host.handlers['settings/mutate'] = (args) {
      expect(args, {
        'ns': 'ui-settings-general',
        'ops': [
          {
            'op': 'set',
            'path': ['welcomeNoticeVersion'],
            'value': '2026-09-28.1',
          },
        ],
        'expectedRevision': 7,
      });
      return {
        'ok': true,
        'value': section({'retainedSetting': 'keep', 'welcomeNoticeVersion': '2026-09-28.1'}, revision: 8),
      };
    };
    expect(await WishEnginePresentation.prepare(client), isTrue);
    expect(host.rpcCalls.where((call) => call['method'] == 'settings/mutate'), hasLength(1));
  });

  test('acknowledged profiles do not write or touch credentials and approvals', () async {
    describe(section({'welcomeNoticeVersion': '2026-09-28.1'}));
    host.handlers['settings/mutate'] = (_) => throw StateError('unexpected write');
    expect(await WishEnginePresentation.prepare(client), isTrue);
    expect(host.rpcCalls.map((call) => call['method']), ['settings/describe']);
  });

  test('missing and read-only settings do not prevent opening a work', () async {
    describe(null);
    expect(await WishEnginePresentation.prepare(client), isFalse);
    describe(section({}), writable: false);
    expect(await WishEnginePresentation.prepare(client), isFalse);
    expect(host.rpcCalls.map((call) => call['method']), ['settings/describe', 'settings/describe']);
  });

  test('refused presentation write stays non-fatal and does not claim success', () async {
    describe(section({}));
    host.handlers['settings/mutate'] = (_) => {
      'ok': false,
      'error': {'code': 'settings/conflict', 'message': 'revision changed'},
    };
    expect(await WishEnginePresentation.prepare(client), isFalse);
  });
}
