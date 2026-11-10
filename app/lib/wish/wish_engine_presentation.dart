import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/foundation.dart';

/// AnyApp owns its consumer onboarding. The embedded engine's developer
/// preview notice must not interrupt a work's first open.
///
/// These values are the official WelcomeNoticeStore contract in
/// @deepseek-ai/dsh-client-ui-settings-models 0.2.1-rc.4, rather than a DOM or
/// localStorage flag. Persisting its one presentation field lets the official
/// UI finish its own onboarding step and release modal focus normally. No
/// credential onboarding, tool approval or Android permission is acknowledged.
abstract final class WishEnginePresentation {
  static const namespace = 'ui-settings-general';
  static const noticeField = 'welcomeNoticeVersion';
  static const noticeVersion = '2026-09-28.1';
  static const _limit = Duration(seconds: 2);

  /// Called after connecting each isolated profile, before creating its page.
  /// An older or read-only engine must remain usable if this optional field
  /// cannot be written; its normal UI remains responsible for its own notice.
  static Future<bool> prepare(DshClient client) async {
    try {
      final section = await client.settingsSection(namespace).timeout(_limit);
      if (section == null) return false;
      if (section.value[noticeField] == noticeVersion) return true;
      if (!section.writable) return false;
      final saved = await client
          .setSetting(namespace, const [noticeField], noticeVersion, expectedRevision: section.revision)
          .timeout(_limit);
      return saved.value[noticeField] == noticeVersion;
    } on Object {
      // Keep this non-fatal and never print settings values or host responses.
      debugPrint('WISH engine presentation preferences unavailable');
      return false;
    }
  }
}
