import 'dart:async';
import 'dart:convert';

import 'package:dsh_app/analytics/anyapp_analytics.dart';
import 'package:dsh_app/analytics/anyapp_umeng.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Store implements AnyappAnalyticsStore {
  String? value;
  int active = 0, maxActive = 0, writes = 0;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String text) async {
    active++;
    if (active > maxActive) maxActive = active;
    await Future<void>.delayed(Duration.zero);
    active--;
    writes++;
    if (fail) throw StateError('not copied into exported events');
    value = text;
  }
}

class _Http implements AnyappAnalyticsTransport {
  final bodies = <Map<String, dynamic>>[];
  final cancellations = <AnyappAnalyticsCancellation>[];
  final statuses = <int>[];
  Completer<int>? blocked;
  @override
  Future<int> post(
    Uri endpoint,
    String body, {
    required Duration timeout,
    required AnyappAnalyticsCancellation cancellation,
  }) async {
    bodies.add(jsonDecode(body) as Map<String, dynamic>);
    cancellations.add(cancellation);
    if (blocked != null) return blocked!.future;
    return statuses.isEmpty ? 204 : statuses.removeAt(0);
  }
}

class _Diagnostics implements AnyappDiagnosticsSdk {
  final grants = <bool>[];
  final events = <Map<String, dynamic>>[];
  bool allowed = true;
  bool fail = false;
  @override
  bool started = false;
  @override
  Future<bool> enable({bool explicitConsent = false}) async {
    grants.add(explicitConsent);
    if (fail) throw StateError('sdk-unavailable');
    started = allowed;
    return allowed;
  }

  @override
  void event(String name, Map<String, dynamic> properties) => events.add({'name': name, ...properties});
  @override
  Future<void> closeAfterOptOut() async {}
}

class _Harness {
  _Harness({this.endpoint = false, this.maxQueue = 200, _Store? storage, AnyappDiagnosticsSdk? diagnostics})
    : store = storage ?? _Store() {
    container = ProviderContainer(
      overrides: [
        anyappAnalyticsConfigProvider.overrideWithValue(
          AnyappAnalyticsConfig(
            store: store,
            transport: http,
            endpoint: endpoint ? Uri.https('analytics.example.test', '/events') : null,
            now: () => now,
            retryBase: const Duration(minutes: 30),
            maxQueue: maxQueue,
            appVersion: '0.10.2+2026110907',
            diagnostics: diagnostics,
          ),
        ),
      ],
    );
    controller = container.read(anyappAnalyticsProvider.notifier);
  }
  final bool endpoint;
  final int maxQueue;
  final _Store store;
  final http = _Http();
  DateTime now = DateTime.utc(2026, 11, 9);
  late final ProviderContainer container;
  late final AnyappAnalytics controller;
  AnyappAnalyticsState get state => container.read(anyappAnalyticsProvider);
  Future<List<dynamic>> events() async => (jsonDecode(await controller.exportJson()) as Map)['events'] as List;
  void dispose() => container.dispose();
}

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('old local consent does not enable third-party diagnostics', () async {
    final store = _Store();
    final old = _Harness(storage: store);
    await old.controller.setEnabled(true);
    old.controller.track(AnyappEvent.appOpen);
    await old.events();
    old.dispose();
    final sdk = _Diagnostics();
    final h = _Harness(storage: store, diagnostics: sdk);
    addTearDown(h.dispose);
    await _until(() => h.state.loaded);
    expect(h.state.enabled, isFalse);
    expect(sdk.grants, isEmpty);
    expect(await h.events(), isEmpty);
  });

  test('explicit consent starts diagnostics and sends only bounded event fields', () async {
    final sdk = _Diagnostics();
    final h = _Harness(diagnostics: sdk);
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    expect(sdk.grants, [true]);
    expect(h.state.diagnosticsReady, isTrue);
    expect((jsonDecode(h.store.value!) as Map)['diagnosticsConsent'], 1);
    h.controller.track(AnyappEvent.workOpen, page: AnyappPage.work, elapsed: const Duration(milliseconds: 20));
    await h.events();
    expect(sdk.events.single, {'name': 'workOpen', 'page': 'work', 'elapsed_ms': 20});
    await h.controller.setEnabled(false);
    h.controller.track(AnyappEvent.creatorStart);
    await h.events();
    expect(sdk.events.length, 1);
  });

  test('failed consent storage never starts the third-party SDK', () async {
    final sdk = _Diagnostics();
    final h = _Harness(storage: _Store()..fail = true, diagnostics: sdk);
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    expect(sdk.grants, isEmpty);
    expect(h.state.enabled, isFalse);
  });

  test('native withdrawal overrides a stale Dart consent record on relaunch', () async {
    final store = _Store();
    final first = _Harness(storage: store, diagnostics: _Diagnostics());
    await first.controller.setEnabled(true);
    first.dispose();
    final sdk = _Diagnostics()..allowed = false;
    final next = _Harness(storage: store, diagnostics: sdk);
    addTearDown(next.dispose);
    await _until(() => next.state.loaded);
    expect(sdk.grants, [false]);
    expect(next.state.enabled, isFalse);
    expect((jsonDecode(store.value!) as Map)['enabled'], isFalse);
  });

  test('SDK startup failure leaves product analytics usable without false readiness', () async {
    final h = _Harness(diagnostics: _Diagnostics()..fail = true);
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    expect(h.state.diagnosticsReady, isFalse);
    expect(h.state.diagnosticsFailed, isTrue);
    h.controller.track(AnyappEvent.workOpen);
    expect((await h.events()).length, 1);
  });

  test('endpoint is independent, HTTPS only, without credentials or upstream fallback', () {
    for (final url in [
      '',
      'http://localhost/events',
      'ftp://example.test/events',
      'https://name:password@example.test/events',
      'https://example.test/events?token=private',
      'https://example.test/events#private',
      'https://dshtui.com/events',
      'https://go.dshtui.com/events',
      'https://GO.DSHTUI.COM./events',
    ]) {
      expect(anyappAnalyticsEndpointFrom(url), isNull, reason: url);
    }
    expect(anyappAnalyticsEndpointFrom('https://metrics.example.test/v1'), isNotNull);
    expect(AnyappAnalyticsConfig().endpoint, isNull);
  });

  test('native transport rejects upstream or insecure URLs before opening a connection', () async {
    for (final value in [
      'https://go.dshtui.com/api/usage/v1',
      'https://DSHTUI.COM../events',
      'http://localhost/events',
      'https://analytics.example.test/events?key=not-allowed',
    ]) {
      await expectLater(
        const AnyappIoAnalyticsTransport().post(
          Uri.parse(value),
          '{}',
          timeout: const Duration(seconds: 1),
          cancellation: AnyappAnalyticsCancellation(),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    }
  });

  test('legacy consent never opts a fresh AnyApp collector in', () async {
    SharedPreferences.setMockInitialValues({'usage.enabled': true, 'anyapp.analytics.consent': true});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final analytics = container.read(anyappAnalyticsProvider.notifier);
    analytics.track(AnyappEvent.appOpen);
    final value = jsonDecode(await analytics.exportJson()) as Map;
    expect(value['enabled'], isFalse);
    expect(value['events'], isEmpty);
    expect(container.read(anyappAnalyticsProvider).loaded, isTrue);
  });

  test('no recording before opt-in; local mode exports only typed event fields', () async {
    final h = _Harness();
    addTearDown(h.dispose);
    h.controller.track(AnyappEvent.loginStart);
    expect(await h.events(), isEmpty);
    await h.controller.setEnabled(true);
    h.controller.track(
      AnyappEvent.presetResult,
      page: AnyappPage.library,
      outcome: AnyappOutcome.success,
      preset: AnyappPreset.voyo,
      elapsed: const Duration(milliseconds: 421),
    );
    final event = (await h.events()).single as Map;
    expect(event.keys.toSet(), {
      'id',
      'event',
      'at',
      'install_id',
      'session_id',
      'app_version',
      'page',
      'outcome',
      'preset',
      'elapsed_ms',
    });
    expect(event['event'], 'presetResult');
    expect(event['elapsed_ms'], 421);
    expect(event['app_version'], '0.10.2+2026110907');
    expect(h.state.status, AnyappAnalyticsStatus.local);
    await h.controller.flush();
    expect(h.http.bodies, isEmpty);
  });

  test('bounded queue drops oldest events and persists mutations serially', () async {
    final h = _Harness(maxQueue: 3);
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    for (var i = 0; i < 8; i++) {
      h.controller.track(AnyappEvent.pageView, elapsed: Duration(milliseconds: i));
    }
    final events = await h.events();
    expect(events.map((e) => (e as Map)['elapsed_ms']).toList(), [5, 6, 7]);
    expect(h.store.maxActive, 1);
    expect((jsonDecode(h.store.value!) as Map)['events'], events);
  });

  test('successful delivery acknowledges only the sent IDs and drains the queue', () async {
    final h = _Harness(endpoint: true);
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.appOpen);
    await h.events();
    await h.controller.flush();
    expect(h.http.bodies, hasLength(1));
    expect((h.http.bodies.single['events'] as List).single['event'], 'appOpen');
    expect(await h.events(), isEmpty);
    expect(h.state.status, AnyappAnalyticsStatus.delivered);
    expect((jsonDecode(h.store.value!) as Map)['events'], isEmpty);
  });

  test('failed send uses backoff and retry keeps identical event IDs', () async {
    final h = _Harness(endpoint: true);
    addTearDown(h.dispose);
    h.http.statuses.addAll([503, 503, 204]);
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.loginResult, outcome: AnyappOutcome.failure);
    await h.events();
    await h.controller.flush();
    expect(h.state.status, AnyappAnalyticsStatus.retry);
    final id = (h.http.bodies.single['events'] as List).single['id'];
    await h.controller.flush();
    expect(h.http.bodies, hasLength(1));
    h.now = h.now.add(const Duration(minutes: 30));
    await h.controller.flush();
    expect(h.http.bodies, hasLength(2));
    h.now = h.now.add(const Duration(minutes: 30));
    await h.controller.flush();
    expect(h.http.bodies, hasLength(2), reason: 'second delay doubles');
    h.now = h.now.add(const Duration(minutes: 30));
    await h.controller.flush();
    expect(h.http.bodies, hasLength(3));
    for (final body in h.http.bodies) {
      expect((body['events'] as List).single['id'], id);
    }
    expect(await h.events(), isEmpty);
  });

  test('concurrent flush calls share one sender; new events drain after acknowledgement', () async {
    final h = _Harness(endpoint: true);
    addTearDown(h.dispose);
    h.http.blocked = Completer<int>();
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.creatorStart);
    await _until(() => h.http.bodies.isNotEmpty);
    final one = h.controller.flush(), two = h.controller.flush();
    expect(identical(one, two), isTrue);
    h.controller.track(AnyappEvent.creatorResult, outcome: AnyappOutcome.success);
    await h.events();
    expect(h.http.bodies, hasLength(1));
    final blocked = h.http.blocked!;
    h.http.blocked = null;
    blocked.complete(204);
    await one;
    expect(h.http.bodies, hasLength(2));
    expect(await h.events(), isEmpty);
  });

  test('revoking consent cancels in-flight request, clears IDs and prevents queued sends', () async {
    final h = _Harness(endpoint: true);
    addTearDown(h.dispose);
    h.http.blocked = Completer<int>();
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.workOpen);
    await _until(() => h.http.bodies.isNotEmpty);
    h.controller.track(AnyappEvent.workReady);
    await h.controller.setEnabled(false);
    expect(h.http.cancellations.single.cancelled, isTrue);
    expect(h.state.enabled, isFalse);
    expect(await h.events(), isEmpty);
    final stored = jsonDecode(h.store.value!) as Map;
    expect(stored.keys.toSet(), {'schema', 'enabled', 'events'});
    h.controller.track(AnyappEvent.pageView);
    final sending = h.controller.flush();
    h.http.blocked!.complete(204);
    await sending;
    expect(h.http.bodies, hasLength(1));
    expect(h.state.status, AnyappAnalyticsStatus.disabled);
  });

  test('local queue survives restart with a fresh session and stable anonymous install ID', () async {
    final store = _Store();
    final first = _Harness(storage: store);
    await first.controller.setEnabled(true);
    first.controller.track(AnyappEvent.appOpen);
    final old = (await first.events()).single as Map;
    first.dispose();
    final second = _Harness(storage: store);
    addTearDown(second.dispose);
    await second.events();
    second.controller.track(AnyappEvent.pageView, page: AnyappPage.settings);
    final events = await second.events();
    expect(events.length, 2);
    final current = events.last as Map;
    expect(current['install_id'], old['install_id']);
    expect(current['session_id'], isNot(old['session_id']));
  });

  test('expired identities and queued events are removed before the next event', () async {
    final h = _Harness();
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.appOpen);
    final old = (await h.events()).single as Map;
    h.now = h.now.add(const Duration(days: 7));
    h.controller.track(AnyappEvent.pageView);
    final current = (await h.events()).single as Map;
    expect(current['install_id'], isNot(old['install_id']));
    expect(current['event'], 'pageView');
  });

  test('clear rotates anonymous identity without changing consent', () async {
    final h = _Harness();
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.appOpen);
    final old = (await h.events()).single as Map;
    await h.controller.clear();
    expect(h.state.enabled, isTrue);
    expect(await h.events(), isEmpty);
    h.controller.track(AnyappEvent.workOpen);
    final current = (await h.events()).single as Map;
    expect(current['install_id'], isNot(old['install_id']));
  });

  test('unrecognized fields in persisted events are never exported or sent', () async {
    final store = _Store();
    final first = _Harness(storage: store);
    await first.controller.setEnabled(true);
    first.controller.track(AnyappEvent.appOpen);
    await first.events();
    first.dispose();
    final saved = jsonDecode(store.value!) as Map;
    ((saved['events'] as List).single as Map)['prompt'] = 'must never survive';
    store.value = jsonEncode(saved);
    final second = _Harness(storage: store);
    addTearDown(second.dispose);
    expect(await second.events(), isEmpty);
    expect(store.value, isNot(contains('must never survive')));
  });

  test('failed consent storage cannot enable recording or network requests', () async {
    final h = _Harness(endpoint: true);
    addTearDown(h.dispose);
    h.store.fail = true;
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.appOpen);
    await h.controller.flush();
    expect(h.state.enabled, isFalse);
    expect(h.http.bodies, isEmpty);
    expect(await h.events(), isEmpty);
    expect(h.state.status, AnyappAnalyticsStatus.storageFailure);
  });

  test('restart preserves retry backoff instead of sending on every app open', () async {
    final store = _Store();
    final first = _Harness(endpoint: true, storage: store);
    first.http.statuses.add(503);
    await first.controller.setEnabled(true);
    first.controller.track(AnyappEvent.appOpen);
    await first.events();
    await first.controller.flush();
    expect(first.state.status, AnyappAnalyticsStatus.retry);
    first.dispose();
    final second = _Harness(endpoint: true, storage: store);
    addTearDown(second.dispose);
    await second.events();
    expect(second.state.status, AnyappAnalyticsStatus.retry);
    await second.controller.flush();
    expect(second.http.bodies, isEmpty);
    second.now = second.now.add(const Duration(minutes: 30));
    await second.controller.flush();
    expect(second.http.bodies, hasLength(1));
    expect(await second.events(), isEmpty);
  });

  test('failed opt-out write still cancels this process and reports storage failure', () async {
    final h = _Harness(endpoint: true);
    addTearDown(h.dispose);
    h.http.blocked = Completer<int>();
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.workOpen);
    await _until(() => h.http.bodies.isNotEmpty);
    h.store.fail = true;
    await h.controller.setEnabled(false);
    expect(h.state.enabled, isFalse);
    expect(h.state.status, AnyappAnalyticsStatus.storageFailure);
    expect(h.http.cancellations.single.cancelled, isTrue);
    h.controller.track(AnyappEvent.workReady);
    final sending = h.controller.flush();
    h.http.blocked!.complete(204);
    await sending;
    expect(h.http.bodies, hasLength(1));
    expect(await h.events(), isEmpty);
    expect(h.state.status, AnyappAnalyticsStatus.storageFailure);
    h.store.fail = false;
    await h.controller.setEnabled(false);
    expect(h.state.status, AnyappAnalyticsStatus.disabled);
    expect((jsonDecode(h.store.value!) as Map)['enabled'], isFalse);
  });

  test('export ages out queued events and updates both storage and count', () async {
    final h = _Harness();
    addTearDown(h.dispose);
    await h.controller.setEnabled(true);
    h.controller.track(AnyappEvent.appOpen);
    expect(await h.events(), hasLength(1));
    h.now = h.now.add(const Duration(days: 7));
    expect(await h.events(), isEmpty);
    expect(h.state.queued, 0);
    expect((jsonDecode(h.store.value!) as Map)['events'], isEmpty);
  });

  test('opt-out before stored consent loads cannot restore the old opt-in', () async {
    final store = _Store();
    final first = _Harness(storage: store);
    await first.controller.setEnabled(true);
    first.controller.track(AnyappEvent.appOpen);
    await first.events();
    first.dispose();
    final second = _Harness(endpoint: true, storage: store);
    addTearDown(second.dispose);
    // Call before the provider's async initial load begins.
    await second.controller.setEnabled(false);
    expect(second.state.enabled, isFalse);
    expect(await second.events(), isEmpty);
    await second.controller.flush();
    expect(second.http.bodies, isEmpty);
    expect((jsonDecode(store.value!) as Map)['enabled'], isFalse);
  });

  test('rapid opt-in then opt-out does not restore consent from a pending write', () async {
    final h = _Harness();
    addTearDown(h.dispose);
    final enabling = h.controller.setEnabled(true);
    final disabling = h.controller.setEnabled(false);
    await Future.wait([enabling, disabling]);
    expect(h.state.enabled, isFalse);
    expect((jsonDecode(h.store.value!) as Map)['enabled'], isFalse);
    expect(await h.events(), isEmpty);
  });
}
