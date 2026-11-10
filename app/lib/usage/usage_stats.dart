// Compatibility shell for retired usage counters. Legacy chat callers may
// still invoke these methods, but no events are counted and no transport runs.
// Only the old usage_stats_* preferences are cleared during initialization.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import '../phone/phone_channel.dart';
import 'usage_ledger.dart';
import 'usage_net.dart';

export 'usage_ledger.dart' show UsageCount;

class UsageStatsState {
  const UsageStatsState({this.loaded = false, this.enabled = false, this.noticed = false});

  final bool loaded;
  final bool enabled;
  final bool noticed;

  /// The retired service never collects, including through old settings pages.
  bool get collecting => false;

  UsageStatsState copyWith({bool? loaded, bool? enabled, bool? noticed}) => UsageStatsState(
    loaded: loaded ?? this.loaded,
    enabled: enabled ?? this.enabled,
    noticed: noticed ?? this.noticed,
  );
}

// Compatibility seams. None is read by the disabled controller.
final usageClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final usageHttpProvider = Provider<UsageHttp>((ref) => const IoUsageHttp());
final usageEndpointProvider = Provider<Uri>((ref) => usageEndpoint);
final usageDeviceProvider = Provider<Future<UsageDevice> Function()>((ref) => const UsageDeviceChannel().read);
final usageLanguageProvider = Provider<String Function()>(
  (ref) =>
      () => AppLocale.current.languageCode,
);
final usageResumesProvider = Provider<VoidCallback Function(VoidCallback onResume)>(
  (ref) =>
      (onResume) => AppLifecycleListener(onResume: onResume).dispose,
);

bool phoneTaskStarted(PhoneTaskStatus before, PhoneTaskStatus now) =>
    now.active && (!before.active || (now.id != null && now.id != before.id));

class UsageStatsController extends Notifier<UsageStatsState> {
  static const enabledKey = 'usage_stats_enabled';
  static const noticedKey = 'usage_stats_noticed';
  static const daysKey = 'usage_stats_days';
  static const iidKey = 'usage_stats_iid';
  static const iidSinceKey = 'usage_stats_iid_since';
  static const failedAtKey = 'usage_stats_failed_at';
  static const closedDayKey = 'usage_stats_closed_day';

  late Future<void> _loaded;

  @override
  UsageStatsState build() {
    // No listeners or sender are attached before, during or after this purge.
    _loaded = _purge();
    return const UsageStatsState();
  }

  Future<void> _purge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(enabledKey, false);
      for (final key in [noticedKey, daysKey, iidKey, iidSinceKey, failedAtKey, closedDayKey]) {
        await prefs.remove(key);
      }
    } catch (_) {
      // A failed preference migration cannot turn this service back on.
    } finally {
      if (ref.mounted) state = const UsageStatsState(loaded: true);
    }
  }

  void count(UsageCount _) {}
  void plugins(int _) {}
  Future<void> foreground() => _loaded;
  Future<void> send() => _loaded;
  Future<void> markNoticed() => _loaded;

  /// Old settings cannot opt into a retired service or consent to AnyApp.
  Future<void> setEnabled(bool _) async {
    await _loaded;
    await _purge();
  }
}

final usageStatsProvider = NotifierProvider<UsageStatsController, UsageStatsState>(UsageStatsController.new);
