import 'package:flutter/services.dart';

/// dsh-wish 自己的相机/通知授权桥；不按权限名堆清单，按功能问。
class WishPermissions {
  static const _channel = MethodChannel('dsh/wish/permissions');

  static Future<Map<String, bool>> status() async {
    try {
      final r = await _channel.invokeMapMethod<String, dynamic>('status');
      return {
        'camera': r?['camera'] == true,
        'microphone': r?['microphone'] == true,
        'notifications': r?['notifications'] == true,
      };
    } catch (_) {
      return {'camera': false, 'microphone': false, 'notifications': false};
    }
  }

  static Future<void> request(String kind) async {
    await _channel.invokeMethod(kind);
  }

  static Future<bool> requestMicrophone() async {
    try {
      final r = await _channel.invokeMapMethod<String, dynamic>('requestMicrophone');
      return r?['microphone'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestCamera() async {
    try {
      final r = await _channel.invokeMapMethod<String, dynamic>('requestCamera');
      return r?['camera'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestNotifications() async {
    try {
      final r = await _channel.invokeMapMethod<String, dynamic>('requestNotifications');
      return r?['notifications'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } catch (_) {}
  }
}
