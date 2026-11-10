import 'dart:convert';

import 'package:flutter/services.dart';

/// One complete Unicode emoji sequence, never an individual UTF-16 character.
class WishEmoji {
  WishEmoji._({
    required this.emoji,
    required this.labelZh,
    required this.labelEn,
    required this.group,
    required this.keywords,
    required this.emojiVersion,
  }) : _searchText = [
         labelZh,
         labelEn,
         ...keywords,
         ...(_groupSearchTerms[group] ?? const <String>[]),
       ].join(' ').toLowerCase();

  final String emoji;
  final String labelZh;
  final String labelEn;
  final String group;
  final List<String> keywords;
  final String emojiVersion;
  final String _searchText;
}

/// Offline Emoji 17.0 catalog, with CLDR 48 Chinese and English annotations.
///
/// It is loaded only when needed, then reused. Artwork comes from the device's
/// emoji font; catalog membership does not promise font support on that device.
class WishEmojiCatalog {
  WishEmojiCatalog._({
    required this.unicodeVersion,
    required this.cldrVersion,
    required this.entries,
    required this.groups,
  }) {
    for (final item in entries) {
      _byEmoji[item.emoji] = item;
      // CLDR stores presentation-independent annotations. Accept pasted text
      // presentation (❤) but return the qualified catalog sequence (❤️).
      _byPresentation[item.emoji.replaceAll('\uFE0F', '')] = item;
      _byGroup.putIfAbsent(item.group, () => <WishEmoji>[]).add(item);
    }
    for (final group in groups) {
      _byGroup[group] = List<WishEmoji>.unmodifiable(_byGroup[group] ?? const <WishEmoji>[]);
    }
  }

  static const assetPath = 'assets/emoji/catalog.json';
  static Future<WishEmojiCatalog>? _defaultLoad;

  final String unicodeVersion;
  final String cldrVersion;
  final List<WishEmoji> entries;
  final List<String> groups;
  final Map<String, WishEmoji> _byEmoji = {};
  final Map<String, WishEmoji> _byPresentation = {};
  final Map<String, List<WishEmoji>> _byGroup = {};

  /// Supplying a bundle bypasses the global cache, useful for isolated tests.
  static Future<WishEmojiCatalog> load({AssetBundle? bundle}) {
    if (bundle != null) return _read(bundle);
    return _defaultLoad ??= _readDefault();
  }

  static Future<WishEmojiCatalog> _readDefault() async {
    try {
      return await _read(rootBundle);
    } catch (_) {
      _defaultLoad = null;
      rethrow;
    }
  }

  static Future<WishEmojiCatalog> _read(AssetBundle bundle) async {
    final raw = jsonDecode(await bundle.loadString(assetPath));
    if (raw is! Map<String, dynamic> || raw['schema'] != 1) {
      throw const FormatException('Unsupported emoji catalog');
    }
    final rawEntries = raw['entries'];
    final rawGroups = raw['groups'];
    if (rawEntries is! List || rawGroups is! List) {
      throw const FormatException('Incomplete emoji catalog');
    }
    final groups = List<String>.unmodifiable(rawGroups.cast<String>());
    final seen = <String>{};
    final entries = <WishEmoji>[];
    for (final row in rawEntries) {
      if (row is! List || row.length != 6 || row[4] is! List) {
        throw const FormatException('Invalid emoji entry');
      }
      final emoji = row[0] as String;
      final group = row[3] as String;
      if (emoji.isEmpty || !seen.add(emoji) || !groups.contains(group)) {
        throw const FormatException('Invalid emoji sequence or group');
      }
      entries.add(
        WishEmoji._(
          emoji: emoji,
          labelZh: row[1] as String,
          labelEn: row[2] as String,
          group: group,
          keywords: List<String>.unmodifiable((row[4] as List).cast<String>()),
          emojiVersion: row[5] as String,
        ),
      );
    }
    return WishEmojiCatalog._(
      unicodeVersion: raw['unicodeVersion'] as String,
      cldrVersion: raw['cldrVersion'] as String,
      entries: List<WishEmoji>.unmodifiable(entries),
      groups: groups,
    );
  }

  /// True only for an exact fully-qualified sequence in the bundled catalog.
  bool contains(String emoji) => _byEmoji.containsKey(emoji);

  /// Resolves exact sequences and harmless text/emoji presentation variants.
  /// It never splits, trims or joins input: multiple emoji are not one icon.
  WishEmoji? entry(String emoji) => _byEmoji[emoji] ?? _byPresentation[emoji];

  String? canonicalize(String emoji) => entry(emoji)?.emoji;

  /// Searches labels and keywords in either language, or a pasted emoji.
  /// Empty queries return all entries in Unicode order; the caller can render
  /// them with a lazy grid. No hidden result cap excludes skin tones or flags.
  List<WishEmoji> search(String query, {String? group}) {
    final source = group == null || group.isEmpty ? entries : _byGroup[group] ?? const <WishEmoji>[];
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return source;
    final pasted = entry(normalized);
    if (pasted != null) {
      return group == null || group.isEmpty || pasted.group == group ? <WishEmoji>[pasted] : const <WishEmoji>[];
    }
    final terms = normalized.split(RegExp(r'\s+'));
    final exact = <WishEmoji>[];
    final matched = <WishEmoji>[];
    for (final item in source) {
      if (!terms.every(item._searchText.contains)) continue;
      if (item.labelZh.toLowerCase() == normalized || item.labelEn.toLowerCase() == normalized) {
        exact.add(item);
      } else {
        matched.add(item);
      }
    }
    return List<WishEmoji>.unmodifiable([...exact, ...matched]);
  }
}

// Additional app-oriented group search terms are authored by AnyApp. Emoji
// labels and per-emoji keywords are derived from licensed Unicode CLDR data.
const _groupSearchTerms = <String, List<String>>{
  'smileys-emotion': ['表情', '笑脸', '情绪', 'smiley', 'emotion'],
  'people-body': ['人物', '人体', '手势', '职业', 'people', 'body', 'gesture'],
  'animals-nature': ['动物', '自然', '植物', 'animal', 'nature', 'plant'],
  'food-drink': ['食物', '饮品', '美食', 'food', 'drink'],
  'travel-places': ['旅行', '旅游', '出行', '交通', '地点', 'travel', 'place'],
  'activities': ['活动', '运动', '游戏', 'activity', 'sport', 'game'],
  'objects': ['物品', '工具', 'object', 'tool'],
  'symbols': ['符号', 'symbol'],
  'flags': ['旗帜', '国旗', 'flag'],
};
