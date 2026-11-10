import 'package:flutter/material.dart';

import 'wish_palette.dart';
import 'wish_glass.dart';
import 'wish_motion.dart';

ThemeData wishTheme(ThemeData base) => base.copyWith(
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      for (final platform in TargetPlatform.values)
        platform: base.pageTransitionsTheme.builders[platform]?.transitionDuration == Duration.zero
            ? const WishPageTransitionsBuilder(instant: true)
            : const WishPageTransitionsBuilder(),
    },
  ),
  splashColor: wishBlue.withValues(alpha: .065),
  highlightColor: wishBlue.withValues(alpha: .035),
  colorScheme: ColorScheme.fromSeed(seedColor: wishBlue, brightness: Brightness.dark, surface: wishSurface),
  scaffoldBackgroundColor: wishBg,
  appBarTheme: base.appBarTheme.copyWith(
    backgroundColor: wishBg,
    surfaceTintColor: Colors.transparent,
    foregroundColor: wishText,
    centerTitle: false,
    titleTextStyle: base.textTheme.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w600, color: wishText),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: wishBlue,
      elevation: 4,
      shadowColor: wishBlue.withValues(alpha: .22),
      foregroundColor: Colors.white,
      minimumSize: const Size(44, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: wishSurfaceAlt,
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  dialogTheme: base.dialogTheme.copyWith(
    backgroundColor: wishSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  bottomSheetTheme: base.bottomSheetTheme.copyWith(
    backgroundColor: wishSurface,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  ),
);

/// Native product chrome. Shared by settings, capability guidance and creation.
class WishPage extends StatelessWidget {
  const WishPage({super.key, required this.title, required this.children, this.actions = const [], this.glass = false});
  final String title;
  final bool glass;
  final List<Widget> children, actions;
  @override
  Widget build(BuildContext context) => Theme(
    data: wishTheme(Theme.of(context)),
    child: Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(
        backgroundColor: wishBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: wishText,
        title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
        actions: actions,
      ),
      body: glass
          ? WishGlassScene(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: children),
            )
          : ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: children),
    ),
  );
}

class WishCard extends StatelessWidget {
  const WishCard({super.key, required this.children, this.title, this.help});
  final List<Widget> children;
  final String? title, help;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A2740), wishSurface],
      ),
      boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, 8))],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x1FFFFFFF)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                title!,
                style: const TextStyle(color: wishText, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          if (help != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Text(help!, style: const TextStyle(color: wishText2, height: 1.5)),
            ),
          ...children,
        ],
      ),
    ),
  );
}

class WishRow extends StatelessWidget {
  const WishRow({super.key, required this.title, this.help, this.icon, this.onTap, this.trailing});
  final String title;
  final String? help;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => WishPressable(
    enabled: onTap != null,
    scale: .992,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: icon == null ? null : Icon(icon, color: wishText2, size: 22),
      title: Text(title, style: const TextStyle(color: wishText, fontSize: 15)),
      subtitle: help == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(help!, style: const TextStyle(color: wishText3, height: 1.45, fontSize: 13)),
            ),
      trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right, color: wishText3, size: 20)),
      onTap: onTap,
    ),
  );
}
