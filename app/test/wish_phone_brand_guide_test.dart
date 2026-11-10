import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/wish/wish_phone_brand_guide.dart';

void main() {
  final zh = lookupL10n(const Locale('zh', 'CN'));
  final en = lookupL10n(const Locale('en'));

  test('consumer sub-brands take precedence over an OEM manufacturer', () {
    expect(WishPhoneBrandGuide.detect(manufacturer: 'OPPO', brand: 'realme'), WishPhoneBrand.realme);
    expect(WishPhoneBrandGuide.detect(manufacturer: 'HUAWEI', brand: 'HONOR'), WishPhoneBrand.honor);
    expect(WishPhoneBrandGuide.detect(manufacturer: 'BBK Electronics', brand: 'iQOO'), WishPhoneBrand.vivo);
    expect(WishPhoneBrandGuide.detect(manufacturer: 'Xiaomi', brand: 'POCO'), WishPhoneBrand.xiaomi);
    expect(WishPhoneBrandGuide.detect(manufacturer: 'unknown', brand: 'One Plus'), WishPhoneBrand.onePlus);
  });

  test('manual overrides roundtrip while unknown input safely falls back', () {
    for (final brand in WishPhoneBrand.values) {
      expect(WishPhoneBrandGuide.parse(brand.id), brand);
      expect(WishPhoneBrandGuide.detect(manufacturer: 'Xiaomi', override: brand.id), brand);
    }
    expect(WishPhoneBrandGuide.detect(manufacturer: 'samsung', override: 'auto'), WishPhoneBrand.samsung);
    expect(WishPhoneBrandGuide.detect(manufacturer: 'samsung', override: 'not-a-brand'), WishPhoneBrand.samsung);
    expect(WishPhoneBrandGuide.detect(brand: 'honorable'), WishPhoneBrand.generic);
    expect(WishPhoneBrandGuide.detect(), WishPhoneBrand.generic);
    expect(WishPhoneBrandGuide.parse('  Google Pixel  '), WishPhoneBrand.pixel);
  });

  test('known older systems do not get inapplicable restricted or pairing steps', () {
    final restricted = WishPhoneBrandGuide.steps(
      WishPhoneBrand.generic,
      WishPhoneGuideTopic.restrictedSettings,
      en,
      sdk: 32,
    );
    expect(restricted, [en.phoneBrandGuideRestrictedOld]);
    expect(WishPhoneBrandGuide.isRelevant(WishPhoneGuideTopic.restrictedSettings, sdk: 32), false);
    expect(WishPhoneBrandGuide.isRelevant(WishPhoneGuideTopic.restrictedSettings, sdk: 33), true);
    final wireless = WishPhoneBrandGuide.steps(
      WishPhoneBrand.generic,
      WishPhoneGuideTopic.wirelessDebugging,
      en,
      sdk: 29,
    );
    expect(wireless, contains(en.phoneBrandGuideWirelessOld));
    expect(wireless, isNot(contains(en.phoneBrandGuideWirelessOpen)));
    expect(WishPhoneBrandGuide.isRelevant(WishPhoneGuideTopic.wirelessDebugging, sdk: 29), false);
    expect(
      WishPhoneBrandGuide.steps(WishPhoneBrand.generic, WishPhoneGuideTopic.exactAlarms, en, sdk: 30),
      contains(en.phoneBrandGuideExactOld),
    );
  });

  test('unknown versions keep conditional help rather than infer a grant', () {
    final steps = WishPhoneBrandGuide.steps(WishPhoneBrand.generic, WishPhoneGuideTopic.restrictedSettings, en);
    expect(steps.first, en.phoneBrandGuideRestrictedWhen);
    expect(steps.last, en.phoneBrandGuideRestrictedReturn);
    expect(WishPhoneBrandGuide.isRelevant(WishPhoneGuideTopic.restrictedSettings), true);
    expect(steps.join(' '), contains('does not itself grant'));
  });

  test('all debugging topics remain explicitly optional and separate from operation', () {
    const advanced = {
      WishPhoneGuideTopic.developerOptions,
      WishPhoneGuideTopic.usbDebugging,
      WishPhoneGuideTopic.wirelessDebugging,
    };
    for (final topic in WishPhoneGuideTopic.values) {
      expect(WishPhoneBrandGuide.requiresDeveloperMode(topic), advanced.contains(topic));
      if (advanced.contains(topic)) {
        expect(WishPhoneBrandGuide.steps(WishPhoneBrand.xiaomi, topic, en).first, en.phoneBrandGuideDeveloperOptional);
      }
    }
    expect(en.phoneBrandGuideDeveloperOptional, contains('does not require'));
    expect(
      WishPhoneBrandGuide.steps(WishPhoneBrand.huawei, WishPhoneGuideTopic.accessibility, en).first,
      contains('4.x or earlier'),
    );
    expect(WishPhoneBrandGuide.caveat(WishPhoneBrand.huawei, en), contains('HarmonyOS 5 / NEXT'));
  });

  test('overlay guidance explains brand route and Android 11 application selection separately', () {
    final xiaomi = WishPhoneBrandGuide.steps(WishPhoneBrand.xiaomi, WishPhoneGuideTopic.overlay, zh, sdk: 36);
    expect(xiaomi.first, zh.anySetupOverlayXiaomi);
    expect(xiaomi, contains(zh.anySetupOverlayListHelp));
    expect(
      WishPhoneBrandGuide.steps(WishPhoneBrand.samsung, WishPhoneGuideTopic.overlay, en, sdk: 36).first,
      en.anySetupOverlaySamsung,
    );
    expect(
      WishPhoneBrandGuide.steps(WishPhoneBrand.generic, WishPhoneGuideTopic.overlay, en, sdk: 29),
      isNot(contains(en.anySetupOverlayListHelp)),
    );
  });

  test('every brand and permission has translated, usable fallback guidance', () {
    for (final language in [zh, en]) {
      for (final brand in WishPhoneBrand.values) {
        expect(WishPhoneBrandGuide.label(brand, language).trim(), isNotEmpty);
        for (final topic in WishPhoneGuideTopic.values) {
          expect(WishPhoneBrandGuide.title(topic, language).trim(), isNotEmpty);
          expect(WishPhoneBrandGuide.searchTerms(topic, language).trim(), isNotEmpty);
          final steps = WishPhoneBrandGuide.steps(brand, topic, language, sdk: 36);
          expect(steps, isNotEmpty);
          expect(steps.every((step) => step.trim().isNotEmpty), true);
          for (final source in WishPhoneBrandGuide.sources(brand, topic)) {
            expect(source.scheme, 'https');
            expect(source.userInfo, isEmpty);
          }
        }
      }
    }
  });
}
