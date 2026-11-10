import 'package:shared_preferences/shared_preferences.dart';

/// App preferences are independent of work data and the engine's global defaults.
class WishPreferences {
  static const fullKey = 'wish.creator.full';
  static Future<bool> fullCreator() async => (await SharedPreferences.getInstance()).getBool(fullKey) ?? true;
  static Future<void> setFullCreator(bool value) async {
    if (!await (await SharedPreferences.getInstance()).setBool(fullKey, value))
      throw StateError('preferences-save-failed');
  }

  static Future<String> permissionPreset() async => await fullCreator() ? 'danger-full-access' : 'workspace-write';
}
