// Retired legacy usage transport. No request can leave this module. The
// native device facts remain available to the independent AnyApp service.

import 'package:flutter/services.dart';

import '../state/app_info.dart';
import 'usage_ledger.dart';

/// The retired transport has no remote default. A build-time environment
/// variable cannot reactivate it; AnyApp analytics uses a separate service.
final defaultUsageEndpoint = Uri(scheme: 'about', path: 'blank');
Uri get usageEndpoint => defaultUsageEndpoint;

/// Retained for compatibility with callers that validate endpoint text.
/// This parser does not enable collection or make the retired transport usable.
Uri? usageEndpointFrom(String text) {
  final uri = Uri.tryParse(text.trim());
  if (uri == null || uri.host.isEmpty) return null;
  final loopback = uri.host == 'localhost' || uri.host == '127.0.0.1';
  return uri.scheme == 'https' || (uri.scheme == 'http' && loopback) ? uri : null;
}

abstract final class UsageBuild {
  static bool get active => false;
}

/// One POST; a seam so tests never touch the network.
abstract interface class UsageHttp {
  /// The response status; throws on a network failure or after [timeout].
  Future<int> post(Uri url, String json, {Duration timeout});
}

class IoUsageHttp implements UsageHttp {
  const IoUsageHttp();

  @override
  Future<int> post(Uri url, String json, {Duration timeout = const Duration(seconds: 10)}) async {
    // Fail before creating a client, even if a legacy caller supplies a URL.
    throw UnsupportedError('legacy-usage-disabled');
  }
}

/// The phone's facts for the body. Without the native side (tests, other
/// platforms) the version from [AppInfo] and nothing else.
class UsageDeviceChannel {
  const UsageDeviceChannel([this.channel = const MethodChannel('dsh/usage')]);

  final MethodChannel channel;

  Future<UsageDevice> read() async {
    final fallback = AppInfo.version.split('+').first;
    try {
      final map = await channel.invokeMapMethod<String, Object?>('device') ?? const {};
      String text(String key) => map[key] is String ? map[key]! as String : '';
      int number(String key) => map[key] is num ? (map[key]! as num).toInt() : 0;
      final app = text('versionName');
      return UsageDevice(
        app: app.isEmpty ? fallback : app,
        build: number('versionCode'),
        sdk: number('sdk'),
        abi: text('abi'),
        maker: usageMaker(text('maker')),
      );
    } on MissingPluginException {
      return UsageDevice(app: fallback);
    } on PlatformException {
      return UsageDevice(app: fallback);
    }
  }
}
