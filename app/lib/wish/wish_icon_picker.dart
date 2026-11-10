import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import 'wish_device.dart';
import 'wish_emoji_catalog.dart';
import 'wish_form.dart';
import 'wish_palette.dart';
import 'wish_icon_art.dart';
import 'wish_identity.dart';

/// One virtualized library; only the selected icon is rasterized.
class WishIconPickerPage extends StatefulWidget {
  const WishIconPickerPage({super.key, this.initialIcon = const {}});
  final Map<String, dynamic> initialIcon;
  @override
  State<WishIconPickerPage> createState() => _WishIconPickerPageState();
}

class _WishIconPickerPageState extends State<WishIconPickerPage> {
  final _search = TextEditingController();
  WishEmojiCatalog? _catalog;
  List<String> _recent = [];
  late Map<String, dynamic> _preview;
  late String _palette;
  String _group = '', _query = '', _mode = 'emoji';
  Map<String, dynamic>? _choice;
  int _revision = 0;
  bool _rendering = false, _applying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _preview = widget.initialIcon;
    _palette = '${widget.initialIcon['palette'] ?? 'indigo'}';
    _load();
  }

  Future<void> _load() async {
    try {
      final catalog = await WishEmojiCatalog.load();
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _error = null;
          _recent = (prefs.getStringList('wish.icons.recent.v1') ?? []).where(catalog.contains).take(24).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.wishIconLibraryFailed);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _groupName(String group) => switch (group) {
    'recent' => appL10n.wishEmojiRecent,
    'smileys-emotion' => appL10n.wishEmojiFaces,
    'people-body' => appL10n.wishEmojiPeople,
    'component' => appL10n.wishEmojiComponents,
    'animals-nature' => appL10n.wishEmojiNature,
    'food-drink' => appL10n.wishEmojiFood,
    'travel-places' => appL10n.wishEmojiTravel,
    'activities' => appL10n.wishEmojiActivities,
    'objects' => appL10n.wishEmojiObjects,
    'symbols' => appL10n.wishEmojiSymbols,
    'flags' => appL10n.wishEmojiFlags,
    _ => appL10n.wishEmojiAll,
  };

  Future<void> _select(Map<String, dynamic> choice) async {
    if (_applying) return;
    FocusScope.of(context).unfocus();
    final revision = ++_revision;
    setState(() {
      _choice = choice;
      _rendering = true;
      _error = null;
    });
    try {
      if (choice['kind'] == 'emoji') {
        final supported = await WishDevice.call<bool>('icon.emojiSupported', args: {'value': choice['emoji']});
        if (supported != true) {
          if (mounted && revision == _revision) {
            setState(() {
              _error = appL10n.wishEmojiUnsupported;
              _rendering = false;
            });
          }
          return;
        }
      }
      final rendered = await WishIconArt.render({...choice, 'palette': _palette, 'variant': 0});
      if (mounted && revision == _revision) {
        setState(() {
          _preview = rendered;
          _rendering = false;
        });
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() {
          _error = appL10n.wishIconRenderFailed;
          _rendering = false;
        });
      }
    }
  }

  Future<void> _apply() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _applying = true;
      _error = null;
    });
    try {
      final icon = wishMap(await WishDevice.call('icon.validate', args: {'value': _preview}));
      final emoji = icon['emoji'];
      if (emoji is String) {
        final prefs = await SharedPreferences.getInstance();
        // A recent-selection write is optional; it must not turn a valid icon into a failed apply.
        try {
          await prefs.setStringList(
            'wish.icons.recent.v1',
            [emoji, ..._recent.where((e) => e != emoji)].take(24).toList(),
          );
        } catch (_) {
          /* Optional history; the staged icon is still valid. */
        }
      }
      if (mounted) Navigator.pop(context, icon);
    } catch (_) {
      if (mounted) {
        setState(() {
          _applying = false;
          _error = appL10n.wishIconRenderFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compact =
        keyboard || MediaQuery.sizeOf(context).height < 620 || MediaQuery.textScalerOf(context).scale(1) > 1.6;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final items = _catalog == null
        ? <WishEmoji>[]
        : _group == 'recent' && _query.isEmpty
        ? _recent.map(_catalog!.entry).whereType<WishEmoji>().toList()
        : _catalog!.search(_query, group: _group.isEmpty || _group == 'recent' ? null : _group);
    final symbols = wishIcons.entries
        .where(
          (e) =>
              _query.isEmpty ||
              e.key.contains(_query.toLowerCase()) ||
              wishIconLabel(e.key).toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(
        title: Text(appL10n.wishIconLibrary),
        actions: [
          IconButton(
            tooltip: appL10n.wishIconColors,
            icon: const Icon(Icons.palette_outlined),
            onPressed: _applying
                ? null
                : () => showModalBottomSheet<void>(
                    context: context,
                    builder: (sheet) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: WishIconPaletteSelector(
                          value: _palette,
                          onChanged: (value) {
                            if (_applying) return;
                            Navigator.pop(sheet);
                            setState(() => _palette = value);
                            if (_choice != null) _select(_choice!);
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: WishIdentityIcon(
                        key: ValueKey(_preview['bitmap'] ?? _preview.toString()),
                        icon: _preview,
                        size: 68,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        '${appL10n.wishIconLibraryHint}\n${appL10n.wishEmojiFontNote}',
                        style: const TextStyle(color: wishText2, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              key: const ValueKey('icon-search-field'),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: appL10n.wishEmojiSearch,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: appL10n.wishIconClearSearch,
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'emoji',
                      label: Text(appL10n.wishEmojiTab),
                      icon: const Icon(Icons.emoji_emotions_outlined),
                    ),
                    ButtonSegment(
                      value: 'glyph',
                      label: Text(appL10n.wishGlyphTab),
                      icon: const Icon(Icons.category_outlined),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) => setState(() => _mode = selection.first),
                ),
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WishIconPaletteSelector(
                  value: _palette,
                  onChanged: (value) {
                    if (_applying) return;
                    setState(() => _palette = value);
                    if (_choice != null) _select(_choice!);
                  },
                ),
              ),
            if (_mode == 'emoji' && !compact)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final group in ['', if (_recent.isNotEmpty) 'recent', ...?_catalog?.groups])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_groupName(group)),
                          selected: _group == group,
                          onSelected: (_) => setState(() => _group = group),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: _mode == 'emoji' && _catalog == null
                  ? Center(
                      child: _error == null
                          ? const CircularProgressIndicator()
                          : TextButton(onPressed: _load, child: Text(appL10n.wishRetry)),
                    )
                  : (_mode == 'emoji' ? items.isEmpty : symbols.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(appL10n.wishEmojiNoResults, textAlign: TextAlign.center),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            (constraints.maxWidth / (MediaQuery.textScalerOf(context).scale(56).clamp(56, 92)))
                                .floor()
                                .clamp(3, 10);
                        return GridView.builder(
                          key: ValueKey('$_mode:$_group:$_query'),
                          padding: const EdgeInsets.all(20),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _mode == 'emoji' ? items.length : symbols.length,
                          itemBuilder: (context, index) {
                            final emoji = _mode == 'emoji' ? items[index] : null;
                            final symbol = _mode == 'glyph' ? symbols[index] : null;
                            final selected = emoji != null
                                ? _preview['emoji'] == emoji.emoji
                                : _preview['kind'] != 'emoji' && _preview['builtin'] == symbol!.key;
                            final label = emoji != null
                                ? (zh ? emoji.labelZh : emoji.labelEn)
                                : wishIconLabel(symbol!.key);
                            return Semantics(
                              label: label,
                              selected: selected,
                              button: true,
                              child: Tooltip(
                                message: label,
                                child: Material(
                                  color: selected ? wishBlue.withValues(alpha: .18) : wishSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: selected ? wishBlue : const Color(0x123F5685), width: 1.5),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: _applying
                                        ? null
                                        : () => _select(
                                            emoji != null
                                                ? {'kind': 'emoji', 'emoji': emoji.emoji}
                                                : {'kind': 'glyph', 'glyph': symbol!.key},
                                          ),
                                    child: Center(
                                      child: ExcludeSemantics(
                                        child: emoji != null
                                            ? Text(
                                                emoji.emoji,
                                                textScaler: TextScaler.noScaling,
                                                style: const TextStyle(
                                                  fontSize: 30,
                                                  fontFamilyFallback: ['Noto Color Emoji', 'Apple Color Emoji'],
                                                ),
                                              )
                                            : Icon(symbol!.value, color: wishText, size: 30),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Text(_error!, style: const TextStyle(color: wishWarm)),
              ),
            if (_rendering || _applying) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _choice != null && !_rendering && !_applying && _error == null ? _apply : null,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(appL10n.wishApplyIcon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishIconPaletteSelector extends StatelessWidget {
  const WishIconPaletteSelector({super.key, required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 14,
    runSpacing: 8,
    children: [
      for (final palette in wishIconPalettes.entries)
        Semantics(
          label: switch (palette.key) {
            'mint' => appL10n.wishPaletteMint,
            'amber' => appL10n.wishPaletteAmber,
            'rose' => appL10n.wishPaletteRose,
            'violet' => appL10n.wishPaletteViolet,
            _ => appL10n.wishPaletteIndigo,
          },
          selected: value == palette.key,
          button: true,
          child: InkResponse(
            onTap: () => onChanged(palette.key),
            radius: 24,
            child: SizedBox.square(
              dimension: 48,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [palette.value[2], palette.value[0]]),
                    border: Border.all(color: value == palette.key ? wishText : Colors.transparent, width: 2.5),
                  ),
                  child: value == palette.key ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
