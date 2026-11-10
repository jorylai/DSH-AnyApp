/// AnyApp's opt-in, content-free product events. This collector deliberately
/// has no free-form properties, device facts, work IDs or legacy telemetry key.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/app_info.dart';

enum AnyappEvent {
  appOpen,
  pageView,
  onboardingStep,
  onboardingContinue,
  onboardingSkip,
  runtimeInstall,
  loginStart,
  loginResult,
  creatorStart,
  creatorResult,
  workOpen,
  workReady,
  presetInstall,
  presetResult,
  workManage,
  permissionResult,
  analyticsPreference,
}

enum AnyappPage {
  welcome,
  runtime,
  capabilities,
  permissions,
  login,
  preset,
  home,
  create,
  work,
  settings,
  library,
  analytics,
}

enum AnyappOutcome { start, success, failure, cancelled, skipped }

enum AnyappPreset { voyo, calorie, radar, pomodoro, imported }

enum AnyappAnalyticsStatus { disabled, local, ready, sending, delivered, retry, storageFailure }

class AnyappAnalyticsState {
  const AnyappAnalyticsState({
    this.loaded = false,
    this.enabled = false,
    this.queued = 0,
    this.endpointConfigured = false,
    this.status = AnyappAnalyticsStatus.disabled,
  });

  final bool loaded;
  final bool enabled;
  final int queued;
  final bool endpointConfigured;
  final AnyappAnalyticsStatus status;
}

/// There is intentionally no endpoint fallback. Builds cannot inherit DSH Go's
/// destination or encode credentials in this URL.
Uri? anyappAnalyticsEndpointFrom(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }
  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'\.+$'), '');
  if (host == 'dshtui.com' || host.endsWith('.dshtui.com')) return null;
  return uri;
}

abstract interface class AnyappAnalyticsStore {
  Future<String?> read();
  Future<void> write(String value);
}

class AnyappPreferencesAnalyticsStore implements AnyappAnalyticsStore {
  const AnyappPreferencesAnalyticsStore();
  static const key = 'anyapp.analytics.v1';

  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String value) async {
    if (!await (await SharedPreferences.getInstance()).setString(key, value)) {
      throw StateError('analytics-storage-failed');
    }
  }
}

/// Revoking consent immediately closes an in-flight native connection, without
/// waiting for its timeout. A request already received by a server cannot be
/// recalled; no queued or subsequent batch is sent after revocation.
class AnyappAnalyticsCancellation {
  bool _cancelled = false;
  void Function()? _onCancel;
  bool get cancelled => _cancelled;

  void onCancel(void Function() callback) {
    _onCancel = callback;
    if (_cancelled) callback();
  }

  void cancel() {
    _cancelled = true;
    _onCancel?.call();
  }
}

abstract interface class AnyappAnalyticsTransport {
  Future<int> post(
    Uri endpoint,
    String body, {
    required Duration timeout,
    required AnyappAnalyticsCancellation cancellation,
  });
}

class AnyappIoAnalyticsTransport implements AnyappAnalyticsTransport {
  const AnyappIoAnalyticsTransport();

  @override
  Future<int> post(
    Uri endpoint,
    String body, {
    required Duration timeout,
    required AnyappAnalyticsCancellation cancellation,
  }) async {
    if (anyappAnalyticsEndpointFrom(endpoint.toString()) == null) {
      throw UnsupportedError('analytics-endpoint-rejected');
    }
    final client = HttpClient()
      ..connectionTimeout = timeout
      ..idleTimeout = const Duration(seconds: 1)
      ..userAgent = 'dsh-anyapp';
    cancellation.onCancel(() => client.close(force: true));
    try {
      if (cancellation.cancelled) throw StateError('analytics-cancelled');
      return await () async {
        final request = await client.postUrl(endpoint);
        if (cancellation.cancelled) throw StateError('analytics-cancelled');
        request.followRedirects = false;
        request.persistentConnection = false;
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        final bytes = utf8.encode(body);
        request.contentLength = bytes.length;
        request.add(bytes);
        final response = await request.close();
        await response.drain<void>();
        return response.statusCode;
      }().timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }
}

/// Injection seam for deterministic local tests. Production uses only the
/// ANYAPP_ANALYTICS_ENDPOINT build value and never opens a test endpoint.
class AnyappAnalyticsConfig {
  AnyappAnalyticsConfig({
    Uri? endpoint,
    this.store = const AnyappPreferencesAnalyticsStore(),
    this.transport = const AnyappIoAnalyticsTransport(),
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 8),
    this.retryBase = const Duration(seconds: 30),
    this.maxQueue = 200,
    this.batchSize = 20,
    this.identityLifetime = const Duration(days: 7),
    this.appVersion = AppInfo.version,
  }) : endpoint = anyappAnalyticsEndpointFrom((endpoint ?? _buildEndpoint)?.toString() ?? ''),
       now = now ?? DateTime.now;

  static final _buildEndpoint = anyappAnalyticsEndpointFrom(const String.fromEnvironment('ANYAPP_ANALYTICS_ENDPOINT'));
  final Uri? endpoint;
  final AnyappAnalyticsStore store;
  final AnyappAnalyticsTransport transport;
  final DateTime Function() now;
  final Duration timeout;
  final Duration retryBase;
  final int maxQueue;
  final int batchSize;
  final Duration identityLifetime;
  final String appVersion;
}

final anyappAnalyticsConfigProvider = Provider<AnyappAnalyticsConfig>((ref) => AnyappAnalyticsConfig());

final anyappAnalyticsProvider = NotifierProvider<AnyappAnalytics, AnyappAnalyticsState>(AnyappAnalytics.new);

class AnyappAnalytics extends Notifier<AnyappAnalyticsState> {
  late AnyappAnalyticsConfig _config;
  final _queue = <_Event>[];
  final _random = Random.secure();
  Future<void> _tail = Future.value();
  Future<void>? _sending;
  AnyappAnalyticsCancellation? _cancellation;
  Timer? _retry;
  DateTime? _notBefore;
  String? _installId;
  DateTime? _installCreated;
  late String _sessionId;
  bool _enabled = false;
  bool _disposed = false;
  int _generation = 0;
  int _failures = 0;

  @override
  AnyappAnalyticsState build() {
    _config = ref.read(anyappAnalyticsConfigProvider);
    _sessionId = _id();
    ref.onDispose(() {
      _disposed = true;
      _retry?.cancel();
      _cancellation?.cancel();
    });
    final generation = _generation;
    unawaited(_serial(() => _load(generation)));
    return AnyappAnalyticsState(endpointConfigured: _config.endpoint != null);
  }

  String _id() => List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  void _publish(AnyappAnalyticsStatus status) {
    if (_disposed) return;
    state = AnyappAnalyticsState(
      loaded: true,
      enabled: _enabled,
      queued: _queue.length,
      endpointConfigured: _config.endpoint != null,
      status: status,
    );
  }

  AnyappAnalyticsStatus get _idle => !_enabled
      ? AnyappAnalyticsStatus.disabled
      : _config.endpoint == null
      ? AnyappAnalyticsStatus.local
      : AnyappAnalyticsStatus.ready;

  Future<void> _serial(Future<void> Function() action) {
    final next = _tail.then((_) async {
      if (_disposed) return;
      try {
        await action();
      } catch (_) {
        _publish(AnyappAnalyticsStatus.storageFailure);
      }
    });
    _tail = next;
    return next;
  }

  Future<void> _load(int generation) async {
    final text = await _config.store.read();
    if (generation != _generation || _disposed) return;
    if (text != null && text.length <= 512000) {
      try {
        final record = jsonDecode(text);
        if (record is Map && record['schema'] == 1 && record['enabled'] == true) {
          final created = DateTime.tryParse('${record['installCreated'] ?? ''}');
          final id = record['installId'];
          if (created != null && _validId(id)) {
            _enabled = true;
            _installId = id as String;
            _installCreated = created.toUtc();
            final events = record['events'];
            if (events is List) {
              for (final raw in events.take(_config.maxQueue)) {
                final event = _Event.parse(raw);
                if (event != null) _queue.add(event);
              }
            }
            final failures = record['failures'];
            _failures = failures is int ? failures.clamp(0, 16) : 0;
            final retryAt = record['retryAt'];
            final parsedRetry = retryAt is String ? DateTime.tryParse(retryAt) : null;
            final now = _config.now();
            if (parsedRetry != null &&
                parsedRetry.isAfter(now) &&
                parsedRetry.difference(now) <= const Duration(hours: 6)) {
              _notBefore = parsedRetry;
              _retry = Timer(parsedRetry.difference(now), () => unawaited(flush()));
            }
            _rotateIfExpired();
            await _persist();
          }
        }
      } on FormatException {
        // Corrupt or foreign records never restore consent or arbitrary fields.
      }
    }
    _publish(_notBefore == null ? _idle : AnyappAnalyticsStatus.retry);
  }

  bool _rotateIfExpired() {
    var changed = false;
    final size = _queue.length;
    final now = _config.now().toUtc();
    final created = _installCreated;
    if (created == null || now.difference(created) >= _config.identityLifetime || created.isAfter(now)) {
      changed = true;
      _installId = _id();
      _installCreated = now;
      _sessionId = _id();
      _queue.clear();
      _failures = 0;
      _notBefore = null;
      _retry?.cancel();
    }
    _queue.removeWhere((e) => now.difference(e.at) >= _config.identityLifetime || e.at.isAfter(now));
    return changed || size != _queue.length;
  }

  Future<void> _persist() => _config.store.write(
    jsonEncode({
      'schema': 1,
      'enabled': _enabled,
      if (_enabled) 'installId': _installId,
      if (_enabled) 'installCreated': _installCreated!.toIso8601String(),
      if (_enabled && _failures > 0) 'failures': _failures,
      if (_enabled && _notBefore != null) 'retryAt': _notBefore!.toIso8601String(),
      'events': _enabled ? _queue.map((e) => e.json).toList() : <Object>[],
    }),
  );

  Future<void> setEnabled(bool enabled) {
    if (!enabled) {
      // Revoke before awaiting queued storage operations or an HTTP response.
      _generation++;
      _enabled = false;
      _queue.clear();
      _installId = null;
      _installCreated = null;
      _sessionId = _id();
      _retry?.cancel();
      _retry = null;
      _notBefore = null;
      _failures = 0;
      _cancellation?.cancel();
      _publish(AnyappAnalyticsStatus.disabled);
    }
    final generation = _generation;
    return _serial(() async {
      if (generation != _generation) return;
      if (enabled && !_enabled) {
        _installId = _id();
        _installCreated = _config.now().toUtc();
        _sessionId = _id();
        _enabled = true;
      }
      try {
        await _persist();
      } catch (_) {
        // A failed opt-in write must never enable network collection.
        _enabled = false;
        _queue.clear();
        _installId = null;
        _installCreated = null;
        rethrow;
      }
      _publish(_idle);
    });
  }

  void track(AnyappEvent event, {AnyappPage? page, AnyappOutcome? outcome, Duration? elapsed, AnyappPreset? preset}) {
    if (!_enabled || _disposed) return;
    final generation = _generation;
    unawaited(
      _serial(() async {
        if (!_enabled || generation != _generation) return;
        _rotateIfExpired();
        final entry = _Event({
          'id': _id(),
          'event': event.name,
          'at': _config.now().toUtc().toIso8601String(),
          'install_id': _installId!,
          'session_id': _sessionId,
          'app_version': RegExp(r'^[a-zA-Z0-9.+_\-]{1,80}$').hasMatch(_config.appVersion)
              ? _config.appVersion
              : 'unknown',
          if (page != null) 'page': page.name,
          if (outcome != null) 'outcome': outcome.name,
          if (preset != null) 'preset': preset.name,
          if (elapsed != null) 'elapsed_ms': elapsed.inMilliseconds.clamp(0, 86400000),
        });
        while (_queue.length >= _config.maxQueue) {
          _queue.removeAt(0);
        }
        _queue.add(entry);
        await _persist();
        _publish(_idle);
        if (_config.endpoint != null) unawaited(flush());
      }),
    );
  }

  /// A single sender owns the head of the persistent queue. Retries reuse event
  /// IDs so a collector can deduplicate a batch acknowledged after a timeout.
  Future<void> flush() {
    if (_sending != null) return _sending!;
    final completer = Completer<void>();
    _sending = completer.future;
    unawaited(() async {
      try {
        await _send();
      } finally {
        _sending = null;
        completer.complete();
        // A new event can arrive just as the previous sender observed an empty
        // queue. Drain it without requiring another foreground transition.
        if (!_disposed &&
            _enabled &&
            _config.endpoint != null &&
            _queue.isNotEmpty &&
            (_notBefore == null || !_config.now().isBefore(_notBefore!))) {
          scheduleMicrotask(() => unawaited(flush()));
        }
      }
    }());
    return completer.future;
  }

  Future<void> _send() async {
    while (!_disposed) {
      List<_Event> batch = const [];
      final generation = _generation;
      await _serial(() async {
        if (!_enabled || _config.endpoint == null) return;
        if (_notBefore != null && _config.now().isBefore(_notBefore!)) return;
        final changed = _rotateIfExpired();
        if (changed) await _persist();
        batch = _queue.take(_config.batchSize).toList();
        if (batch.isEmpty && changed) _publish(_idle);
        if (batch.isNotEmpty) _publish(AnyappAnalyticsStatus.sending);
      });
      if (batch.isEmpty || !_enabled || generation != _generation) return;
      final cancel = AnyappAnalyticsCancellation();
      _cancellation = cancel;
      var delivered = false;
      try {
        final status = await _config.transport
            .post(
              _config.endpoint!,
              jsonEncode({'schema': 'dsh-anyapp.analytics/1', 'events': batch.map((e) => e.json).toList()}),
              timeout: _config.timeout,
              cancellation: cancel,
            )
            .timeout(_config.timeout);
        delivered = status >= 200 && status < 300;
      } catch (_) {
        // Only a safe status is exposed; exception strings can include URLs.
      } finally {
        cancel.cancel();
        if (identical(_cancellation, cancel)) _cancellation = null;
      }
      if (_disposed || !_enabled || generation != _generation) return;
      await _serial(() async {
        if (!_enabled || generation != _generation) return;
        if (delivered) {
          final ids = batch.map((e) => e.json['id']).toSet();
          _queue.removeWhere((e) => ids.contains(e.json['id']));
          _failures = 0;
          _notBefore = null;
          _retry?.cancel();
          _retry = null;
          await _persist();
          _publish(AnyappAnalyticsStatus.delivered);
        } else {
          _failures = min(_failures + 1, 16);
          final delayMs = min(
            _config.retryBase.inMilliseconds * (1 << (_failures - 1)),
            const Duration(hours: 6).inMilliseconds,
          );
          final delay = Duration(milliseconds: delayMs);
          _notBefore = _config.now().add(delay);
          _retry?.cancel();
          _retry = Timer(delay, () => unawaited(flush()));
          await _persist();
          _publish(AnyappAnalyticsStatus.retry);
        }
      });
      if (!delivered) return;
    }
  }

  /// Erase pending events and unlink future events from the previous random ID.
  Future<void> clear() {
    _generation++;
    _cancellation?.cancel();
    _retry?.cancel();
    _retry = null;
    _notBefore = null;
    _failures = 0;
    _queue.clear();
    _installId = _enabled ? _id() : null;
    _installCreated = _enabled ? _config.now().toUtc() : null;
    _sessionId = _id();
    return _serial(() async {
      await _persist();
      _publish(_idle);
    });
  }

  Future<String> exportJson() async {
    var result = '{"schema":"dsh-anyapp.analytics/1","enabled":false,"events":[]}';
    await _serial(() async {
      final changed = _enabled && _rotateIfExpired();
      result = const JsonEncoder.withIndent('  ').convert({
        'schema': 'dsh-anyapp.analytics/1',
        'enabled': _enabled,
        'events': _enabled ? _queue.map((e) => e.json).toList() : <Object>[],
      });
      if (changed) {
        await _persist();
        _publish(_idle);
      }
    });
    return result;
  }
}

bool _validId(Object? value) => value is String && RegExp(r'^[a-f0-9]{32}$').hasMatch(value);

class _Event {
  _Event(this.json);
  final Map<String, Object> json;
  DateTime get at => DateTime.parse(json['at']! as String);

  static _Event? parse(Object? raw) {
    if (raw is! Map) return null;
    const keys = {
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
    };
    if (raw.keys.any((key) => !keys.contains(key)) ||
        !_validId(raw['id']) ||
        !_validId(raw['install_id']) ||
        !_validId(raw['session_id']) ||
        !AnyappEvent.values.any((e) => e.name == raw['event']) ||
        raw['at'] is! String ||
        DateTime.tryParse(raw['at'] as String) == null ||
        raw['app_version'] is! String ||
        !RegExp(r'^[a-zA-Z0-9.+_\-]{1,80}$').hasMatch(raw['app_version'] as String)) {
      return null;
    }
    if (raw.containsKey('page') && !AnyappPage.values.any((e) => e.name == raw['page'])) return null;
    if (raw.containsKey('outcome') && !AnyappOutcome.values.any((e) => e.name == raw['outcome'])) return null;
    if (raw.containsKey('preset') && !AnyappPreset.values.any((e) => e.name == raw['preset'])) return null;
    if (raw.containsKey('elapsed_ms') &&
        (raw['elapsed_ms'] is! int || (raw['elapsed_ms'] as int) < 0 || (raw['elapsed_ms'] as int) > 86400000)) {
      return null;
    }
    return _Event(Map<String, Object>.from(raw));
  }
}
