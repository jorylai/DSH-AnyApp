import 'package:dsh_app/wish/wish_emoji_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingBundle extends CachingAssetBundle {
  int loads = 0;

  @override
  Future<ByteData> load(String key) {
    loads++;
    return rootBundle.load(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WishEmojiCatalog catalog;

  setUpAll(() async {
    catalog = await WishEmojiCatalog.load();
  });

  test('bundles all Emoji 17 fully-qualified sequences with both languages', () {
    expect(catalog.unicodeVersion, '17.0');
    expect(catalog.cldrVersion, '48');
    expect(catalog.entries, hasLength(3944));
    expect(catalog.entries.map((item) => item.emoji).toSet(), hasLength(3944));
    expect(catalog.groups, hasLength(9));
    expect(catalog.search('', group: 'people-body'), hasLength(2418));
    expect(catalog.search('', group: 'flags'), hasLength(270));
    expect(catalog.entries.every((item) => item.labelZh.isNotEmpty), isTrue);
    expect(catalog.entries.every((item) => item.labelEn.isNotEmpty), isTrue);
    expect(catalog.entries.every((item) => item.keywords.isNotEmpty), isTrue);
    // Emoji 17 additions must not be lost through an old source URL or CLDR.
    expect(catalog.contains('\u{1FAEA}'), isTrue); // Distorted face.
    expect(catalog.contains('\u{1FAEF}'), isTrue); // Fight cloud.
  });

  test('preserves complete skin-tone, family, flag, keycap and tag sequences', () {
    const sequences = [
      '🧑🏽‍💻',
      '👨‍👩‍👧‍👦',
      '🇨🇳',
      '1️⃣',
      '🏴\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}',
      '🧑🏿‍🤝‍🧑🏻',
    ];
    for (final emoji in sequences) {
      expect(catalog.contains(emoji), isTrue, reason: emoji);
      expect(catalog.search(emoji).single.emoji, emoji);
    }
    expect(catalog.contains('🏻'), isFalse); // A modifier alone is not an icon.
    expect(catalog.entry('🍎🍐'), isNull);
    expect(catalog.entry('hello'), isNull);
    expect(catalog.entry('🧑🏽‍'), isNull);
    expect(catalog.entry(''), isNull);
  });

  test('searches Chinese and English annotations and meaningful aliases', () {
    expect(catalog.search('番茄').map((item) => item.emoji), contains('🍅'));
    expect(catalog.search('tomato').first.emoji, '🍅');
    expect(catalog.search('码农').map((item) => item.emoji), contains('🧑🏽‍💻'));
    expect(catalog.search('avocado').map((item) => item.emoji), contains('🥑'));
    expect(catalog.search('酪梨').map((item) => item.emoji), contains('🥑'));
    expect(catalog.search('US').map((item) => item.emoji), contains('🇺🇸'));
    expect(catalog.search('  RED   HEART  ').map((item) => item.emoji), contains('❤️'));
    expect(catalog.search('旅行').map((item) => item.emoji), contains('✈️'));
    expect(catalog.search('not_a_real_emoji_term'), isEmpty);
  });

  test('group filter constrains real search and never silently truncates', () {
    expect(catalog.search(''), same(catalog.entries));
    expect(catalog.search('', group: 'food-drink'), hasLength(131));
    expect(catalog.search('animal', group: 'food-drink'), isEmpty);
    expect(catalog.search('🍅', group: 'flags'), isEmpty);
    expect(catalog.search('', group: 'unknown'), isEmpty);
    expect(catalog.search('🧑🏽‍💻', group: 'people-body').single.emoji, '🧑🏽‍💻');
  });

  test('canonicalizes presentation aliases without accepting whitespace or text', () {
    expect(catalog.contains('❤'), isFalse);
    expect(catalog.canonicalize('❤'), '❤️');
    expect(catalog.canonicalize('✈'), '✈️');
    expect(catalog.canonicalize('1⃣'), '1️⃣');
    expect(catalog.search('❤').single.emoji, '❤️');
    expect(catalog.canonicalize(' ❤️'), isNull);
    expect(catalog.canonicalize('❤️ '), isNull);
    expect(catalog.canonicalize('❤️❤️'), isNull);
    expect(catalog.canonicalize('a❤️'), isNull);
    expect(catalog.canonicalize('❤️\uFE0F'), isNull);
    expect(catalog.canonicalize('\uFE0F❤'), isNull);
  });

  test('load reuses the default catalog and supports an isolated asset bundle', () async {
    expect(await WishEmojiCatalog.load(), same(catalog));
    final bundle = _CountingBundle();
    final isolated = await WishEmojiCatalog.load(bundle: bundle);
    expect(bundle.loads, 1);
    expect(isolated.entries, hasLength(3944));
    expect(isolated, isNot(same(catalog)));
    expect(() => isolated.entries.clear(), throwsUnsupportedError);
    expect(() => isolated.groups.clear(), throwsUnsupportedError);
    expect(() => isolated.entries.first.keywords.clear(), throwsUnsupportedError);
  });
}
