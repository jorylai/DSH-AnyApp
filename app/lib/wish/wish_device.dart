import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Only Flutter supplies the work namespace; browser arguments cannot select another work.
class WishDevice {
  static final entryVisibility = ValueNotifier<Map<String, dynamic>>({});
  static const channel = MethodChannel('dsh/wish/device');
  static Future<T?> call<T>(String method, {String? work, Map<String, dynamic> args = const {}}) =>
      channel.invokeMethod<T>(method, {...args, if (work != null) 'work': work});
  static Future<Map<String, dynamic>> summary(String work) async {
    final value = await status(work);
    final phone = (value['phoneStatus'] as Map?) ?? {};
    final a11y = (phone['a11y'] as Map?) ?? {};
    return {
      for (final name in [
        'phone',
        'reminders',
        'notifications',
        'exact',
        'overlay',
        'files',
        'batteryExempt',
        'calendar',
        'location',
        'notificationAccess',
        'background',
      ])
        name: value[name] == true,
      'phoneEnabled': phone['enabled'] == true,
      'phoneToolsMounted': phone['bridgeListening'] == true,
      'accessibilityConnected': a11y['serviceConnected'] == true,
      'life': value['life'] ?? {},
      'aiDirect': true,
    };
  }

  static Future<Map<String, dynamic>> status([String? work]) async =>
      ((await call<Map>('status', work: work)) ?? {}).cast<String, dynamic>();
}
