import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import 'wish_palette.dart';
import 'wish_glass.dart';
import 'wish_identity.dart';
import 'wish_material.dart';
import 'wish_motion.dart';
import 'wish_wall_order.dart';

class WishGalleryItem {
  const WishGalleryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.icon = const {},
    this.ready = false,
  });
  final String id, title, description, status;
  final Map<String, dynamic> icon;
  final bool ready;
}

/// The same presentation is used in the app and in visual review, with no fake runtime state.
class WishGallery extends StatelessWidget {
  const WishGallery({
    super.key,
    required this.items,
    required this.sort,
    required this.onSort,
    required this.onOpen,
    required this.onManage,
    required this.onCreate,
    required this.onLibrary,
    required this.onSettings,
    this.busy = false,
    this.error,
  });
  final List<WishGalleryItem> items;
  final WishWallSort sort;
  final ValueChanged<WishWallSort> onSort;
  final ValueChanged<int> onOpen, onManage;
  final VoidCallback onCreate, onLibrary, onSettings;
  final bool busy;
  final String? error;
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: wishBg),
      child: Scaffold(
        backgroundColor: wishBg,
        body: WishGlassScene(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                  child: Row(
                    children: [
                      const WishBrandMark(size: 34),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          appL10n.wishBrandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: wishText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .25,
                          ),
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width >= 360 && scale <= 1.2)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: wishSurfaceAlt.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x18FFFFFF)),
                          ),
                          child: Text(
                            appL10n.wishMadeByYou,
                            style: const TextStyle(color: Color(0xFFADBDF6), fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
                if (busy) const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: WishEntrance(child: _GalleryHero(onCreate: onCreate)),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 0, 20, 14),
                          child: Row(
                            children: [
                              Text(
                                appL10n.wishMyCreations,
                                style: const TextStyle(
                                  color: wishText,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${items.length}', style: const TextStyle(color: wishText3, fontSize: 12)),
                              const Spacer(),
                              PopupMenuButton<WishWallSort>(
                                tooltip: appL10n.wishWallSort,
                                initialValue: sort,
                                onSelected: onSort,
                                color: wishSurfaceAlt,
                                itemBuilder: (_) => [
                                  for (final value in WishWallSort.values)
                                    CheckedPopupMenuItem(
                                      value: value,
                                      checked: sort == value,
                                      child: Text(
                                        value == WishWallSort.added ? appL10n.wishWallNewest : appL10n.wishWallRecent,
                                      ),
                                    ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        sort == WishWallSort.added ? appL10n.wishWallNewest : appL10n.wishWallRecent,
                                        style: const TextStyle(color: wishText2, fontSize: 12),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.expand_more_rounded, size: 17, color: wishText2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (error != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            child: Text(error!, style: const TextStyle(color: wishWarm)),
                          ),
                        ),
                      if (items.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            child: Container(
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0x24FFFFFF)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.spa_outlined, color: Color(0xFFA6DCCF), size: 30),
                                  const SizedBox(height: 15),
                                  Text(
                                    appL10n.wishFirstCreation,
                                    style: const TextStyle(color: wishText2, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => WishEntrance(
                              key: ValueKey(items[i].id),
                              order: i + 1,
                              enabled: i < 6,
                              child: _GalleryCard(item: items[i], onOpen: () => onOpen(i), onManage: () => onManage(i)),
                            ),
                            childCount: items.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.sizeOf(context).width < 360 || scale > 1.3 ? 1 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 220 + (scale - 1).clamp(0, 2) * 110,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _GalleryDock(onLibrary: onLibrary, onSettings: onSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryHero extends StatelessWidget {
  const _GalleryHero({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => WishGlassSurface(
    radius: 28,
    emphasis: true,
    child: Stack(
      children: [
        const Positioned(right: -45, top: -30, child: IgnorePointer(child: WishSeedArtwork(size: 230))),
        Padding(
          padding: const EdgeInsets.all(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appL10n.wishHomeEyebrow,
                style: const TextStyle(
                  color: Color(0xFFAFBDFF),
                  fontSize: 10,
                  letterSpacing: 2.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                appL10n.wishHomePoem,
                style: const TextStyle(
                  color: wishText,
                  fontSize: 30,
                  height: 1.23,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                appL10n.wishHomeInvitation,
                style: const TextStyle(color: Color(0xFFB4BFCD), fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 23),
              WishRitualButton(
                label: appL10n.wishStartCreator,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onCreate();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GalleryCard extends StatefulWidget {
  const _GalleryCard({required this.item, required this.onOpen, required this.onManage});
  final WishGalleryItem item;
  final VoidCallback onOpen, onManage;
  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return WishPressable(
      child: WishGlassSurface(
        radius: 23,
        seed: item.id.codeUnits.fold<int>(0, (sum, n) => sum + n) % 17 / 5,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(23),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onOpen,
            onLongPress: widget.onManage,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 14, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WishIdentityIcon(icon: item.icon, size: 43),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: appL10n.wishWorkMenu,
                        onPressed: widget.onManage,
                        icon: const Icon(Icons.more_horiz_rounded, color: wishText2, size: 21),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: wishText,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: wishText2, fontSize: 12, height: 1.5),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: item.ready ? const Color(0xFF83CDB6) : const Color(0xFFE4B85B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: item.ready ? const Color(0xFFA6C9C1) : wishText2, fontSize: 11),
                        ),
                      ),
                      const Icon(Icons.north_east_rounded, size: 16, color: Color(0xFFAABBF5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryDock extends StatelessWidget {
  const _GalleryDock({required this.onLibrary, required this.onSettings});
  final VoidCallback onLibrary, onSettings;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
      child: WishGlassSurface(
        radius: 23,
        emphasis: true,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              _DockItem(icon: Icons.grid_view_rounded, label: appL10n.wishCreationsTab, selected: true, onTap: () {}),
              _DockItem(icon: Icons.lightbulb_outline_rounded, label: appL10n.wishIdeasTab, onTap: onLibrary),
              _DockItem(icon: Icons.tune_rounded, label: appL10n.wishSettings, onTap: onSettings),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DockItem extends StatelessWidget {
  const _DockItem({required this.icon, required this.label, required this.onTap, this.selected = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => Expanded(
    child: WishPressable(
      child: Material(
        color: selected ? const Color(0x254D6BFE) : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: selected ? const Color(0xFFB8C5FF) : wishText2),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? wishText : wishText2,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
