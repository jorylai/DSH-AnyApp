import '../l10n/l10n.dart';

/// A routing hint for human-readable guidance, never a permission verdict.
/// Prefer the consumer brand over manufacturer (e.g. realme manufactured by
/// OPPO). Unknown values retain the generic Android route.
enum WishPhoneBrand {
  xiaomi,
  huawei,
  honor,
  oppo,
  onePlus,
  realme,
  vivo,
  samsung,
  pixel,
  generic;

  String get id => this == onePlus ? 'oneplus' : name;
}

enum WishPhoneGuideTopic {
  accessibility,
  restrictedSettings,
  overlay,
  background,
  autostart,
  popup,
  notifications,
  notificationAccess,
  exactAlarms,
  developerOptions,
  usbDebugging,
  wirelessDebugging,
  camera,
  microphone,
  location,
  calendar,
  files,
  screenCapture,
}

/// Reviewed against the official help linked by [sources] on 2026-11-09.
/// OEM paths are examples, not an assertion that a given menu is installed.
/// No settings are changed and no developer option is required by this guide.
abstract final class WishPhoneBrandGuide {
  static WishPhoneBrand? parse(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]'), '');
    return switch (normalized) {
      'xiaomi' || 'redmi' || 'poco' || 'mi' || '小米' || '红米' => WishPhoneBrand.xiaomi,
      'huawei' || '华为' => WishPhoneBrand.huawei,
      'honor' || '荣耀' => WishPhoneBrand.honor,
      'oppo' => WishPhoneBrand.oppo,
      'oneplus' || '一加' => WishPhoneBrand.onePlus,
      'realme' || '真我' => WishPhoneBrand.realme,
      'vivo' || 'iqoo' => WishPhoneBrand.vivo,
      'samsung' || '三星' => WishPhoneBrand.samsung,
      'google' || 'pixel' || 'googlepixel' => WishPhoneBrand.pixel,
      'generic' || 'other' || 'android' || '其他' => WishPhoneBrand.generic,
      _ => null,
    };
  }

  static WishPhoneBrand detect({String? manufacturer, String? brand, String? override}) =>
      parse(override) ?? parse(brand) ?? parse(manufacturer) ?? WishPhoneBrand.generic;

  static String label(WishPhoneBrand brand, L10n l10n) => switch (brand) {
    WishPhoneBrand.xiaomi => l10n.phoneBrandXiaomi,
    WishPhoneBrand.huawei => l10n.phoneBrandHuawei,
    WishPhoneBrand.honor => l10n.phoneBrandHonor,
    WishPhoneBrand.oppo => l10n.phoneBrandOppo,
    WishPhoneBrand.onePlus => l10n.phoneBrandOnePlus,
    WishPhoneBrand.realme => l10n.phoneBrandRealme,
    WishPhoneBrand.vivo => l10n.phoneBrandVivo,
    WishPhoneBrand.samsung => l10n.phoneBrandSamsung,
    WishPhoneBrand.pixel => l10n.phoneBrandPixel,
    WishPhoneBrand.generic => l10n.phoneBrandGeneric,
  };

  static String title(WishPhoneGuideTopic topic, L10n l10n) => switch (topic) {
    WishPhoneGuideTopic.accessibility => l10n.phoneBrandGuideA11yTitle,
    WishPhoneGuideTopic.restrictedSettings => l10n.phoneBrandGuideRestrictedTitle,
    WishPhoneGuideTopic.overlay => l10n.phoneBrandGuideOverlayTitle,
    WishPhoneGuideTopic.background => l10n.phoneBrandGuideBackgroundTitle,
    WishPhoneGuideTopic.autostart => l10n.phoneBrandGuideAutostartTitle,
    WishPhoneGuideTopic.popup => l10n.phoneBrandGuidePopupTitle,
    WishPhoneGuideTopic.notifications => l10n.phoneBrandGuideNotificationsTitle,
    WishPhoneGuideTopic.notificationAccess => l10n.phoneBrandGuideNotificationAccessTitle,
    WishPhoneGuideTopic.exactAlarms => l10n.phoneBrandGuideExactTitle,
    WishPhoneGuideTopic.developerOptions => l10n.phoneBrandGuideDeveloperTitle,
    WishPhoneGuideTopic.usbDebugging => l10n.phoneBrandGuideUsbTitle,
    WishPhoneGuideTopic.wirelessDebugging => l10n.phoneBrandGuideWirelessTitle,
    WishPhoneGuideTopic.camera => l10n.phoneBrandGuideCameraTitle,
    WishPhoneGuideTopic.microphone => l10n.phoneBrandGuideMicrophoneTitle,
    WishPhoneGuideTopic.location => l10n.phoneBrandGuideLocationTitle,
    WishPhoneGuideTopic.calendar => l10n.phoneBrandGuideCalendarTitle,
    WishPhoneGuideTopic.files => l10n.phoneBrandGuideFilesTitle,
    WishPhoneGuideTopic.screenCapture => l10n.phoneBrandGuideCaptureTitle,
  };

  static String caveat(WishPhoneBrand brand, L10n l10n) => brand == WishPhoneBrand.huawei
      ? '${l10n.phoneBrandGuideCaveat}\n${l10n.phoneBrandGuideHuaweiCaveat}'
      : l10n.phoneBrandGuideCaveat;

  static bool requiresDeveloperMode(WishPhoneGuideTopic topic) =>
      topic == WishPhoneGuideTopic.developerOptions ||
      topic == WishPhoneGuideTopic.usbDebugging ||
      topic == WishPhoneGuideTopic.wirelessDebugging;

  /// Unknown SDKs keep conditional guidance visible rather than asserting that
  /// a setting exists. Callers must use the native status to show grant state.
  static bool isRelevant(WishPhoneGuideTopic topic, {int? sdk}) {
    if (sdk == null) return true;
    return switch (topic) {
      WishPhoneGuideTopic.restrictedSettings => sdk >= 33,
      WishPhoneGuideTopic.wirelessDebugging => sdk >= 30,
      WishPhoneGuideTopic.exactAlarms => sdk >= 31,
      _ => true,
    };
  }

  static List<String> steps(WishPhoneBrand brand, WishPhoneGuideTopic topic, L10n l10n, {int? sdk}) => switch (topic) {
    WishPhoneGuideTopic.accessibility => [
      _accessibilityRoute(brand, l10n),
      l10n.phoneBrandGuideA11ySelect,
      l10n.phoneBrandGuideA11yConfirm,
      l10n.phoneBrandGuideA11yVerify,
    ],
    WishPhoneGuideTopic.restrictedSettings =>
      sdk != null && sdk < 33
          ? [l10n.phoneBrandGuideRestrictedOld]
          : [
              l10n.phoneBrandGuideRestrictedWhen,
              l10n.phoneBrandGuideRestrictedInfo,
              l10n.phoneBrandGuideRestrictedMenu,
              l10n.phoneBrandGuideRestrictedReturn,
            ],
    WishPhoneGuideTopic.overlay => [
      _overlayRoute(brand, l10n),
      if (sdk == null || sdk >= 30) l10n.anySetupOverlayListHelp,
      l10n.phoneBrandGuideOverlayAllow,
    ],
    WishPhoneGuideTopic.background => [
      _backgroundRoute(brand, l10n),
      if (brand == WishPhoneBrand.xiaomi) l10n.phoneBrandGuideBatteryXiaomi,
      l10n.phoneBrandGuideBackgroundLimits,
    ],
    WishPhoneGuideTopic.autostart => [
      if ({WishPhoneBrand.xiaomi, WishPhoneBrand.huawei, WishPhoneBrand.honor, WishPhoneBrand.vivo}.contains(brand))
        _backgroundRoute(brand, l10n)
      else
        l10n.phoneBrandGuideAutostartGeneric,
      l10n.phoneBrandGuideBackgroundLimits,
    ],
    WishPhoneGuideTopic.popup => [
      brand == WishPhoneBrand.xiaomi ? l10n.phoneBrandGuidePopupXiaomi : l10n.phoneBrandGuidePopupGeneric,
    ],
    WishPhoneGuideTopic.notifications => [
      l10n.phoneBrandGuideNotificationsFind,
      l10n.phoneBrandGuideNotificationsVerify,
    ],
    WishPhoneGuideTopic.notificationAccess => [
      l10n.phoneBrandGuideNotificationAccessFind,
      l10n.phoneBrandGuideNotificationAccessConfirm,
    ],
    WishPhoneGuideTopic.exactAlarms => [
      sdk != null && sdk < 31 ? l10n.phoneBrandGuideExactOld : l10n.phoneBrandGuideExactFind,
      l10n.phoneBrandGuideExactVerify,
    ],
    WishPhoneGuideTopic.developerOptions => [
      l10n.phoneBrandGuideDeveloperOptional,
      brand == WishPhoneBrand.xiaomi ? l10n.phoneBrandGuideDeveloperXiaomi : l10n.phoneBrandGuideDeveloperFind,
      l10n.phoneBrandGuideDeveloperReturn,
    ],
    WishPhoneGuideTopic.usbDebugging => [
      l10n.phoneBrandGuideDeveloperOptional,
      l10n.phoneBrandGuideUsbOpen,
      l10n.phoneBrandGuideUsbConfirm,
      l10n.phoneBrandGuideUsbClose,
    ],
    WishPhoneGuideTopic.wirelessDebugging => [
      l10n.phoneBrandGuideDeveloperOptional,
      sdk != null && sdk < 30 ? l10n.phoneBrandGuideWirelessOld : l10n.phoneBrandGuideWirelessOpen,
      l10n.phoneBrandGuideWirelessNoClient,
    ],
    WishPhoneGuideTopic.camera => [l10n.phoneBrandGuideCameraStep],
    WishPhoneGuideTopic.microphone => [l10n.phoneBrandGuideMicrophoneStep],
    WishPhoneGuideTopic.location => [l10n.phoneBrandGuideLocationStep],
    WishPhoneGuideTopic.calendar => [l10n.phoneBrandGuideCalendarStep],
    WishPhoneGuideTopic.files => [l10n.phoneBrandGuideFilesStep],
    WishPhoneGuideTopic.screenCapture => [l10n.phoneBrandGuideCaptureStep, l10n.phoneBrandGuideCaptureProtected],
  };

  static String searchTerms(WishPhoneGuideTopic topic, L10n l10n) => switch (topic) {
    WishPhoneGuideTopic.accessibility => l10n.phoneBrandGuideSearchA11y,
    WishPhoneGuideTopic.restrictedSettings => l10n.phoneBrandGuideSearchRestricted,
    WishPhoneGuideTopic.overlay => l10n.phoneBrandGuideSearchOverlay,
    WishPhoneGuideTopic.background => l10n.phoneBrandGuideSearchBackground,
    WishPhoneGuideTopic.autostart => l10n.phoneBrandGuideSearchAutostart,
    WishPhoneGuideTopic.popup => l10n.phoneBrandGuideSearchPopup,
    WishPhoneGuideTopic.notifications => l10n.phoneBrandGuideSearchNotifications,
    WishPhoneGuideTopic.notificationAccess => l10n.phoneBrandGuideSearchNotificationAccess,
    WishPhoneGuideTopic.exactAlarms => l10n.phoneBrandGuideSearchExact,
    WishPhoneGuideTopic.developerOptions => l10n.phoneBrandGuideSearchDeveloper,
    WishPhoneGuideTopic.usbDebugging => l10n.phoneBrandGuideSearchUsb,
    WishPhoneGuideTopic.wirelessDebugging => l10n.phoneBrandGuideSearchWireless,
    WishPhoneGuideTopic.camera => l10n.phoneBrandGuideSearchCamera,
    WishPhoneGuideTopic.microphone => l10n.phoneBrandGuideSearchMicrophone,
    WishPhoneGuideTopic.location => l10n.phoneBrandGuideSearchLocation,
    WishPhoneGuideTopic.calendar => l10n.phoneBrandGuideSearchCalendar,
    WishPhoneGuideTopic.files => l10n.phoneBrandGuideSearchFiles,
    WishPhoneGuideTopic.screenCapture => l10n.phoneBrandGuideSearchCapture,
  };

  static String _accessibilityRoute(WishPhoneBrand brand, L10n l10n) => switch (brand) {
    WishPhoneBrand.xiaomi => l10n.phoneBrandGuideA11yXiaomi,
    WishPhoneBrand.huawei => l10n.phoneBrandGuideA11yHuawei,
    WishPhoneBrand.honor => l10n.phoneBrandGuideA11yHonor,
    WishPhoneBrand.oppo || WishPhoneBrand.onePlus || WishPhoneBrand.realme => l10n.phoneBrandGuideA11yColor,
    WishPhoneBrand.vivo => l10n.phoneBrandGuideA11yVivo,
    WishPhoneBrand.samsung => l10n.phoneBrandGuideA11ySamsung,
    WishPhoneBrand.pixel || WishPhoneBrand.generic => l10n.phoneBrandGuideA11yGeneric,
  };

  static String _overlayRoute(WishPhoneBrand brand, L10n l10n) => switch (brand) {
    WishPhoneBrand.xiaomi => l10n.anySetupOverlayXiaomi,
    WishPhoneBrand.huawei || WishPhoneBrand.honor => l10n.anySetupOverlayHuawei,
    WishPhoneBrand.oppo || WishPhoneBrand.onePlus || WishPhoneBrand.realme => l10n.anySetupOverlayColor,
    WishPhoneBrand.vivo => l10n.anySetupOverlayVivo,
    WishPhoneBrand.samsung => l10n.anySetupOverlaySamsung,
    WishPhoneBrand.pixel || WishPhoneBrand.generic => l10n.phoneBrandGuideOverlayFind,
  };

  static String _backgroundRoute(WishPhoneBrand brand, L10n l10n) => switch (brand) {
    WishPhoneBrand.xiaomi => l10n.phoneBrandGuideBackgroundXiaomi,
    WishPhoneBrand.huawei => l10n.phoneBrandGuideBackgroundHuawei,
    WishPhoneBrand.honor => l10n.phoneBrandGuideBackgroundHonor,
    WishPhoneBrand.oppo || WishPhoneBrand.onePlus || WishPhoneBrand.realme => l10n.phoneBrandGuideBackgroundColor,
    WishPhoneBrand.vivo => l10n.phoneBrandGuideBackgroundVivo,
    WishPhoneBrand.samsung => l10n.phoneBrandGuideBackgroundSamsung,
    WishPhoneBrand.pixel || WishPhoneBrand.generic => l10n.phoneBrandGuideBackgroundGeneric,
  };

  /// Official source links, intended for a user-invoked “Manufacturer help”
  /// action. No URL is opened automatically and no device data is appended.
  static List<Uri> sources(WishPhoneBrand brand, WishPhoneGuideTopic topic) {
    final common = switch (topic) {
      WishPhoneGuideTopic.restrictedSettings => 'https://support.google.com/android/answer/12623953',
      WishPhoneGuideTopic.developerOptions => 'https://developer.android.com/studio/debug/dev-options',
      WishPhoneGuideTopic.usbDebugging ||
      WishPhoneGuideTopic.wirelessDebugging => 'https://developer.android.com/tools/adb',
      WishPhoneGuideTopic.exactAlarms =>
        'https://developer.android.com/develop/background-work/services/alarms/schedule',
      WishPhoneGuideTopic.files => 'https://developer.android.com/training/data-storage/shared/documents-files',
      WishPhoneGuideTopic.screenCapture => 'https://developer.android.com/media/grow/media-projection',
      WishPhoneGuideTopic.notificationAccess =>
        'https://developer.android.com/reference/android/service/notification/NotificationListenerService',
      WishPhoneGuideTopic.camera ||
      WishPhoneGuideTopic.microphone ||
      WishPhoneGuideTopic.location ||
      WishPhoneGuideTopic.calendar ||
      WishPhoneGuideTopic.notifications => 'https://support.google.com/android/answer/9431959',
      WishPhoneGuideTopic.overlay =>
        'https://developer.android.com/reference/android/provider/Settings#ACTION_MANAGE_OVERLAY_PERMISSION',
      WishPhoneGuideTopic.popup => 'https://developer.android.com/guide/components/activities/background-starts',
      _ => null,
    };
    if (common != null) {
      return [
        Uri.parse(common),
        if (brand == WishPhoneBrand.xiaomi && topic == WishPhoneGuideTopic.developerOptions)
          Uri.parse('https://www.mi.com/global/support/faq/details/KA-497657/'),
      ];
    }
    final isA11y = topic == WishPhoneGuideTopic.accessibility;
    final source = switch (brand) {
      WishPhoneBrand.xiaomi =>
        isA11y
            ? 'https://www.mi.com/global/support/faq/details/KA-728047/'
            : 'https://www.mi.com/global/support/faq/details/KA-497677/',
      WishPhoneBrand.huawei => 'https://consumer.huawei.com/cn/support/content/zh-cn00410039/',
      WishPhoneBrand.honor =>
        isA11y
            ? 'https://www.honor.com/cn/support/content/zh-cn15890904/'
            : 'https://www.honor.com/cn/support/content/zh-cn00428704/',
      WishPhoneBrand.oppo => isA11y ? 'https://support.oppo.com/ph/answer/?aid=2045427' : 'https://s3.ap-southeast-1.amazonaws.com/sgp-sow-cms-oppo-com/cms/userManual/manual/f888f4f6-4f81-4759-8aaa-115f25e31bb4/ColorOS_14.0_User_Manual_V1.0_20231227.pdf',
      WishPhoneBrand.onePlus =>
        'https://service.oneplus.com/content/dam/support/user-manuals/common/OxygenOS_14.0_User_Manual.pdf',
      WishPhoneBrand.realme =>
        isA11y
            ? 'https://r1.realme.net/general/20230130/1675070322576.pdf'
            : 'https://www.realme.com/in/support/kw/doc/2083586',
      WishPhoneBrand.vivo => isA11y ? 'https://accessibility.vivo.com/detail/single' : 'https://asia-exstatic-vivofs.vivo.com/PSee2l50xoirPK7y/1786937316335/a750af09a331046cb70960bb6fe16eb1.pdf',
      WishPhoneBrand.samsung =>
        isA11y
            ? 'https://www.samsung.com/us/support/answer/ANS10001906/'
            : 'https://www.samsung.com/us/support/answer/ANS10002534/',
      WishPhoneBrand.pixel || WishPhoneBrand.generic =>
        isA11y
            ? 'https://support.google.com/accessibility/android/answer/6006564'
            : 'https://support.google.com/pixelphone/answer/6090599',
    };
    return [Uri.parse(source)];
  }
}
