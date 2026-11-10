import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dsh_app/usage/usage_ledger.dart';
import 'package:dsh_app/usage/usage_net.dart';
import 'package:dsh_app/usage/usage_stats.dart';

class _RecordingHttp implements UsageHttp {
  int calls = 0;
  @override
  Future<int> post(Uri url, String json, {Duration timeout = const Duration(seconds: 10)}) async {
    calls++;
    return 204;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('old consent, queued days and install id are purged without HTTP or listeners', () async {
    final ledger = UsageLedger()..count(UsageCount.turns, DateTime(2026, 11, 8));
    SharedPreferences.setMockInitialValues({
      UsageStatsController.enabledKey: true,
      UsageStatsController.noticedKey: true,
      UsageStatsController.daysKey: ledger.encode(),
      UsageStatsController.iidKey: 'AAAAAAAAAAAAAAAAAAAAAA',
      UsageStatsController.iidSinceKey: DateTime(2026, 11, 1).millisecondsSinceEpoch,
      UsageStatsController.failedAtKey: DateTime(2026, 11, 8).millisecondsSinceEpoch,
      UsageStatsController.closedDayKey: '2026-11-07',
      'wish.onboard.welcome': true,
      'anyapp.analytics.consent': true,
    });
    final http = _RecordingHttp();
    var listeners = 0, deviceReads = 0;
    final container = ProviderContainer(
      overrides: [
        usageHttpProvider.overrideWithValue(http),
        usageEndpointProvider.overrideWithValue(Uri.https('go.dshtui.com', '/api/usage/v1')),
        usageClockProvider.overrideWithValue(() => DateTime(2026, 11, 9)),
        usageResumesProvider.overrideWithValue((onResume) {
          listeners++;
          return () {};
        }),
        usageDeviceProvider.overrideWithValue(() async {
          deviceReads++;
          return const UsageDevice(app: '0.10.2', build: 2026110907, sdk: 36, abi: 'arm64-v8a', maker: 'test');
        }),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(usageStatsProvider.notifier);
    // Calls made before asynchronous migration are harmless as well.
    controller.count(UsageCount.turns);
    controller.plugins(8);
    await controller.foreground();
    await controller.send();
    await controller.markNoticed();
    await controller.setEnabled(true);
    for (final count in UsageCount.values) {
      controller.count(count);
    }
    await controller.foreground();
    expect(http.calls, 0);
    expect(listeners, 0);
    expect(deviceReads, 0);
    final state = container.read(usageStatsProvider);
    expect(state.loaded, isTrue);
    expect(state.enabled, isFalse);
    expect(state.noticed, isFalse);
    expect(state.collecting, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(UsageStatsController.enabledKey), isFalse);
    for (final key in [
      UsageStatsController.noticedKey,
      UsageStatsController.daysKey,
      UsageStatsController.iidKey,
      UsageStatsController.iidSinceKey,
      UsageStatsController.failedAtKey,
      UsageStatsController.closedDayKey,
    ]) {
      expect(prefs.containsKey(key), isFalse, reason: key);
    }
    expect(prefs.getBool('wish.onboard.welcome'), isTrue);
    expect(prefs.getBool('anyapp.analytics.consent'), isTrue);
  });

  test('retired transport rejects an explicit upstream URL before creating a client', () async {
    expect(UsageBuild.active, isFalse);
    expect(usageEndpoint, Uri(scheme: 'about', path: 'blank'));
    await expectLater(
      const IoUsageHttp().post(Uri.https('go.dshtui.com', '/api/usage/v1'), '{}'),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
