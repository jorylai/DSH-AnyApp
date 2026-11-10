import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

import '../share_code/guest_fs.dart';
import '../analytics/anyapp_analytics.dart';
import 'wish_creator.dart';
import 'wish_form.dart';
import 'wish_preset_installer.dart';
import 'wish_preset_cache.dart';

/// Eligibility is recorded before onboarding installs the runtime. An upgrade,
/// including an empty old wall, must not silently receive duplicate examples.
class WishPresetBootstrap {
  static const preferenceKey = 'wish.presets.bootstrap.v1';
  static const names = ['radar', 'pomodoro'];
  static const _legacyNames = ['voyo', 'calorie'];
  static Future<void>? _initializing;

  static bool eligible({required Set<String> preferenceKeys, required bool runtimePresent}) =>
      !runtimePresent &&
      !preferenceKeys.any(
        (key) =>
            key.startsWith('wish.onboard.') ||
            key.startsWith('wish-wall-') ||
            key.startsWith('wish-actions:') ||
            key.startsWith('wish-agent:'),
      );

  static Future<void> initialize() {
    final active = _initializing;
    if (active != null) return active;
    final task = _initialize();
    _initializing = task;
    return task.whenComplete(() {
      if (identical(_initializing, task)) _initializing = null;
    });
  }

  static Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(preferenceKey)) {
      final previous = _read(prefs);
      if (previous['version'] != 3) await _save(prefs, migrateLegacy(previous));
      return;
    }
    final fresh = eligible(preferenceKeys: prefs.getKeys(), runtimePresent: await GuestFs.local() != null);
    await _save(prefs, {
      'version': 3,
      'mode': fresh ? 'pending' : 'skipped',
      'ids': {
        if (fresh)
          for (final name in names) name: newWishId(),
      },
      'progress': <String, dynamic>{},
    });
  }

  /// Replace only a recorded starter plan. Its old identities remain available
  /// for reversible wall filtering; their code, data and profiles are untouched.
  /// Existing user installations without a starter plan never receive examples.
  static Map<String, dynamic> migrateLegacy(Map<String, dynamic> previous) {
    if (previous['version'] == 3) return previous;
    final legacy = previous['version'] == 1 ? previous : previous['legacyPlan'];
    final retired = retiredStarterIds(previous).isNotEmpty;
    if (previous['version'] == 2 && (previous['mode'] != 'skipped' || !retired)) {
      // A current pair may already be partially installed or complete. Keep
      // both its target IDs and pinned package versions across this migration.
      return {...previous, 'version': 3};
    }
    final pending = retired;
    return {
      'version': 3,
      'mode': pending ? 'pending' : 'skipped',
      'ids': {
        if (pending)
          for (final name in names) name: newWishId(),
      },
      'progress': <String, dynamic>{},
      if (legacy is Map) 'legacyPlan': legacy,
    };
  }

  /// Never infer ownership from a title: a person's Voyo or calorie coach is
  /// distinct from the two random IDs allocated by the old preload plan.
  static Set<String> retiredStarterIds(Map<String, dynamic> plan) {
    final legacy = plan['version'] == 1 ? plan : plan['legacyPlan'];
    if (legacy is! Map || legacy['version'] != 1 || !['pending', 'complete'].contains(legacy['mode'])) return {};
    final raw = legacy['ids'];
    if (raw is! Map) return {};
    final ids = <String>{};
    for (final name in _legacyNames) {
      final id = raw[name];
      if (id is! String || !RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(id)) return {};
      ids.add(id);
    }
    if (ids.length != _legacyNames.length) return {};
    // A corrupt state must not hide a currently installed replacement.
    final current = plan['version'] == 1 ? null : plan['ids'];
    if (current is Map && current.values.any(ids.contains)) return {};
    return ids;
  }

  static Future<Set<String>> hiddenStarterIds() async {
    await initialize();
    return retiredStarterIds(_read(await SharedPreferences.getInstance()));
  }

  static Map<String, dynamic> _read(SharedPreferences prefs) {
    final decoded = jsonDecode(prefs.getString(preferenceKey)!);
    if (decoded is! Map) throw const FormatException('invalid-preset-state');
    final value = decoded.cast<String, dynamic>();
    if (![1, 2, 3].contains(value['version']) ||
        !['pending', 'skipped', 'complete'].contains(value['mode']) ||
        value['ids'] is! Map ||
        value['progress'] is! Map) {
      throw const FormatException('invalid-preset-state');
    }
    if (value['mode'] != 'skipped') {
      final pair = value['version'] == 1 ? _legacyNames : names;
      final ids = wishMap(value['ids']);
      if (pair.any(
            (name) => ids[name] is! String || !RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(ids[name] as String),
          ) ||
          ids[pair.first] == ids[pair.last]) {
        throw const FormatException('invalid-preset-state');
      }
    }
    return value;
  }

  static Future<void> _save(SharedPreferences prefs, Map<String, dynamic> state) async {
    if (!await prefs.setString(preferenceKey, jsonEncode(state))) throw StateError('preset-progress-not-saved');
  }

  static Future<bool> pending() async {
    await initialize();
    return _read(await SharedPreferences.getInstance())['mode'] == 'pending';
  }

  static Future<void> run(ProviderContainer container, {void Function(String name, int ready)? onProgress}) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    final plan = _read(prefs);
    if (plan['mode'] != 'pending') return;
    final ids = wishMap(plan['ids']);
    final progress = wishMap(plan['progress']);
    final support = await getApplicationSupportDirectory();
    final cache = WishPresetPackageCache(
      Directory('${support.path}/wish-starter-packages'),
      loadAsset: (name) => rootBundle.loadString('assets/presets/$name.anyapp'),
    );
    final packages = <String, Map<String, dynamic>>{};
    // Pin both versions before the first engine mutation. Each cache write is
    // atomic and validated; only small identities/stages go into preferences.
    for (final name in names) {
      final raw = progress[name];
      final previous = raw == null ? null : WishPackageInstallState.fromJson(wishMap(raw));
      if (previous != null && previous.id != ids[name]) throw const FormatException('invalid-preset-state');
      final envelope = await cache.prepare(ids[name] as String, name, expectedHash: previous?.sourceHash);
      packages[name] = envelope;
      if (previous == null) {
        progress[name] = WishPackageInstallState.initial(envelope, id: ids[name] as String).toJson();
        plan['progress'] = progress;
        await _save(prefs, plan);
      }
    }
    var ready = 0;
    for (final name in names) {
      onProgress?.call(name, ready);
      final envelope = packages[name]!;
      final state = WishPackageInstallState.fromJson(wishMap(progress[name]));
      final analytics = container.read(anyappAnalyticsProvider.notifier);
      final preset = name == 'radar' ? AnyappPreset.radar : AnyappPreset.pomodoro;
      final timer = Stopwatch()..start();
      final installing = state.stage != WishInstallStage.published;
      if (installing)
        analytics.track(
          AnyappEvent.presetInstall,
          page: AnyappPage.preset,
          preset: preset,
          outcome: AnyappOutcome.start,
        );
      try {
        await WishPresetInstaller.install(
          container,
          envelope,
          state: state,
          save: (next) async {
            progress[name] = next.toJson();
            plan['progress'] = progress;
            await _save(prefs, plan);
          },
        );
        if (installing)
          analytics.track(
            AnyappEvent.presetResult,
            page: AnyappPage.preset,
            preset: preset,
            outcome: AnyappOutcome.success,
            elapsed: timer.elapsed,
          );
      } catch (_) {
        if (installing)
          analytics.track(
            AnyappEvent.presetResult,
            page: AnyappPage.preset,
            preset: preset,
            outcome: AnyappOutcome.failure,
            elapsed: timer.elapsed,
          );
        rethrow;
      }
      ready++;
      onProgress?.call(name, ready);
    }
    plan['mode'] = 'complete';
    await _save(prefs, plan);
  }
}
