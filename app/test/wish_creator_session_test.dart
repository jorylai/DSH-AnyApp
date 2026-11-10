import 'package:dsh_app/wish/wish_creator_session.dart';
import 'package:dsh_app/wish/wish_preferences.dart';
import 'package:dsh_app/wish/wish_project.dart';
import 'package:dsh_client/dsh_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Host host;
  late DshClient client;
  setUp(() {
    SharedPreferences.setMockInitialValues({WishPreferences.fullKey: false});
    host = _Host();
    client = DshClient.withCarrier(host);
  });
  tearDown(() => client.close());

  test('imported work gets a verified Creator session before it is bound', () async {
    final work = await ensureWishCreatorSession(client, WishProject(_project));
    expect(work.id, 'local-radar');
    expect(work.sessionId, 'session-new-creator');
    final create = host.calls.singleWhere((call) => call.$1 == 'session/create').$2['request'] as Map;
    expect(create, {'workspaceId': 'workspace-radar', 'agentPreset': 'cordis'});
    expect(host.calls.singleWhere((call) => call.$1 == 'workspace/create').$2['request'], {
      'path': '/root/.dsh/wish/workspaces/local-radar',
    });
    expect(host.endpoints.indexOf('session/projections'), lessThan(host.endpoints.indexOf('wishMobile/bind')));
    expect(host.endpoints.indexOf('commands/execute'), lessThan(host.endpoints.indexOf('wishMobile/bind')));
    expect(host.endpoints.indexOf('session/selectModel'), lessThan(host.endpoints.indexOf('wishMobile/bind')));
    expect(host.calls.singleWhere((call) => call.$1 == 'wishMobile/bind').$2, {
      'form': 'local-radar',
      'sessionId': 'session-new-creator',
    });
    expect(host.endpoints, isNot(contains('session/prompt')));
  });

  test('continuing an existing Creator preserves its conversation and selected model', () async {
    final original = WishProject({..._project, 'sessionId': 'session-existing-creator'});
    final work = await ensureWishCreatorSession(client, original);
    expect(work, same(original));
    expect(host.calls.singleWhere((call) => call.$1 == 'session/projections').$2['request'], {
      'sessionId': 'session-existing-creator',
    });
    expect(host.calls.singleWhere((call) => call.$1 == 'commands/execute').$2['agentId'], 'session-existing-creator');
    for (final endpoint in [
      'session/create',
      'session/selectModel',
      'wishMobile/bind',
      'wishMobile/modelStatus',
      'session/prompt',
    ]) {
      expect(host.endpoints, isNot(contains(endpoint)));
    }
  });

  test('a healthy preset listing cannot disguise a non-Creator active projection', () async {
    host.activePreset = 'standard';
    await expectLater(
      ensureWishCreatorSession(client, WishProject(_project)),
      throwsA(isA<StateError>().having((error) => error.message, 'code', 'creator-preset-not-active')),
    );
    expect(host.endpoints, isNot(contains('wishMobile/bind')));
    expect(host.endpoints, isNot(contains('commands/execute')));
  });

  test('an imported empty legacy Creator is attached without changing its session id', () async {
    host.blank = true;
    final work = await ensureWishCreatorSession(
      client,
      WishProject({..._project, 'sessionId': 'session-existing-creator'}),
    );
    expect(work.sessionId, 'session-existing-creator');
    expect(host.calls.singleWhere((call) => call.$1 == 'session/create').$2['request'], {
      'workspaceId': 'workspace-radar',
      'sessionId': 'session-existing-creator',
      'agentPreset': 'cordis',
    });
    expect(host.endpoints, isNot(contains('session/prompt')));
    expect(host.endpoints, isNot(contains('wishMobile/bind')));
  });

  test('a confirmed missing imported session gets a new local Creator binding', () async {
    host.missing = true;
    final work = await ensureWishCreatorSession(client, WishProject({..._project, 'sessionId': 'session-missing'}));
    expect(work.sessionId, 'session-new-creator');
    expect(host.endpoints, contains('wishMobile/bind'));
    expect(host.endpoints, isNot(contains('session/prompt')));
  });

  test('an existing non-Creator conversation is not replaced or silently converted', () async {
    host.activePreset = 'standard';
    await expectLater(
      ensureWishCreatorSession(client, WishProject({..._project, 'sessionId': 'session-keep-history'})),
      throwsStateError,
    );
    for (final endpoint in ['session/create', 'agentPresets/select', 'wishMobile/bind', 'session/selectModel']) {
      expect(host.endpoints, isNot(contains(endpoint)));
    }
  });

  test('a broken Creator preset stops before allocating or binding a session', () async {
    host.broken = true;
    await expectLater(ensureWishCreatorSession(client, WishProject(_project)), throwsStateError);
    expect(host.endpoints, ['agentPresets/list']);
  });

  test('permission failure cannot bind a partially configured imported session', () async {
    host.permissionAccepted = false;
    await expectLater(ensureWishCreatorSession(client, WishProject(_project)), throwsStateError);
    expect(host.endpoints, isNot(contains('wishMobile/bind')));
    expect(host.endpoints, isNot(contains('session/selectModel')));
  });

  test('only a genuinely unfinished missing plugin is presented as a draft', () {
    const missing = DshRemoteException('wish/plugin-not-installed', 'not installed');
    expect(wishPreviewIsDraft(WishProject({..._project, 'state': 'draft', 'panel': null}), missing), isTrue);
    expect(wishPreviewIsDraft(WishProject(_project), missing), isFalse);
    expect(wishPreviewIsDraft(WishProject({..._project, 'state': 'draft'}), missing), isFalse);
    expect(
      wishPreviewIsDraft(
        WishProject({..._project, 'state': 'draft', 'panel': null}),
        const DshRemoteException('gateway/internal', 'temporary connection error'),
      ),
      isFalse,
    );
  });
}

const _project = <String, dynamic>{'id': 'local-radar', 'title': '比价雷达', 'state': 'published', 'panel': 'local-radar'};

class _Host extends DshCarrier {
  final calls = <(String, Map<String, Object?>)>[];
  String activePreset = 'cordis';
  bool broken = false, permissionAccepted = true, blank = false, missing = false;
  List<String> get endpoints => calls.map((call) => call.$1).toList();
  @override
  String get kind => 'test';
  @override
  DshTracer? get tracer => null;
  @override
  Future<RpcResult> call(String endpoint, Map<String, Object?> args, {Duration? timeout}) async {
    calls.add((endpoint, args));
    return RpcOk(switch (endpoint) {
      'agentPresets/list' => {
        'presets': [
          {'id': 'cordis', if (broken) 'broken': 'unavailable'},
        ],
      },
      'session/initializeDefaultModel' => null,
      'workspace/create' => {
        'created': true,
        'workspace': {
          'workspaceId': 'workspace-radar',
          'path': '/root/.dsh/wish/workspaces/local-radar',
          'sessionIds': [],
        },
      },
      'wishMobile/modelStatus' => {'ready': true, 'provider': 'deepseek', 'model': 'test-model'},
      'session/create' => {
        'sessionId': (args['request'] as Map)['sessionId'] ?? 'session-new-creator',
        'agentPreset': 'cordis',
      },
      'session/projections' =>
        missing && (args['request'] as Map)['sessionId'] == 'session-missing'
            ? null
            : {
                'asOfSeq': 0,
                'values': {
                  'agentPreset': activePreset,
                  'sessionListMetadata': {'blank': blank},
                },
              },
      'permissionPresets/catalog' => {
        'options': [
          {'value': 'workspace-write'},
        ],
      },
      'commands/execute' => {
        'result': {'kind': permissionAccepted ? 'success' : 'error'},
      },
      'session/selectModel' => {'provider': 'deepseek', 'model': 'test-model'},
      'wishMobile/bind' => {..._project, 'sessionId': args['sessionId']},
      _ => throw StateError('unexpected RPC: $endpoint'),
    });
  }

  @override
  Future<DshMuxLink> openLink(MuxOptions options) => throw UnsupportedError('no streams');
  @override
  Future<void> close() async {}
}
