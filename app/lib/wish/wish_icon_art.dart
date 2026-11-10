import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'wish_emoji_catalog.dart';
import 'wish_icon_designer.dart';

const wishIcons = <String, IconData>{
  'spark': Icons.auto_awesome_outlined,
  'timer': Icons.timer_outlined,
  'camera': Icons.camera_alt_outlined,
  'assistant': Icons.smart_toy_outlined,
  'trip': Icons.explore_outlined,
  'cart': Icons.shopping_bag_outlined,
  'note': Icons.notes_rounded,
  'heart': Icons.favorite_border,
  'calendar': Icons.calendar_month_outlined,
  'plane': Icons.flight_outlined,
  'book': Icons.auto_stories_outlined,
  'music': Icons.music_note_outlined,
  'weather': Icons.wb_sunny_outlined,
  'fitness': Icons.fitness_center_outlined,
  'translate': Icons.translate_rounded,
  'code': Icons.code_rounded,
  'receipt': Icons.receipt_long_outlined,
  'globe': Icons.language_outlined,
  'mail': Icons.mail_outline_rounded,
  'chart': Icons.insights_rounded,
  'wallet': Icons.account_balance_wallet_outlined,
  'home': Icons.home_outlined,
  'work': Icons.work_outline_rounded,
  'search': Icons.search_rounded,
  'lightning': Icons.bolt_rounded,
  'leaf': Icons.eco_outlined,
  'coffee': Icons.coffee_outlined,
  'restaurant': Icons.restaurant_rounded,
  'pet': Icons.pets_outlined,
  'gift': Icons.card_giftcard_outlined,
  'photo': Icons.photo_outlined,
  'video': Icons.movie_outlined,
  'headphones': Icons.headphones_outlined,
  'mic': Icons.mic_none_rounded,
  'language': Icons.language_rounded,
  'map': Icons.map_outlined,
  'compass': Icons.explore_outlined,
  'train': Icons.train_outlined,
  'bike': Icons.pedal_bike_rounded,
  'car': Icons.directions_car_outlined,
  'walk': Icons.directions_walk_rounded,
  'bed': Icons.bedtime_outlined,
  'health': Icons.monitor_heart_outlined,
  'brain': Icons.psychology_outlined,
  'moon': Icons.nightlight_outlined,
  'cloud': Icons.cloud_outlined,
  'rain': Icons.water_drop_outlined,
  'water': Icons.waves_rounded,
  'flower': Icons.local_florist_outlined,
  'tree': Icons.park_outlined,
  'rocket': Icons.rocket_launch_outlined,
  'robot': Icons.smart_toy_outlined,
  'game': Icons.sports_esports_outlined,
  'paint': Icons.brush_outlined,
  'palette': Icons.palette_outlined,
  'pencil': Icons.edit_outlined,
  'folder': Icons.folder_outlined,
  'document': Icons.description_outlined,
  'scan': Icons.document_scanner_outlined,
  'qr': Icons.qr_code_rounded,
  'lock': Icons.lock_outline_rounded,
  'shield': Icons.shield_outlined,
  'key': Icons.key_outlined,
  'link': Icons.link_rounded,
  'bookmark': Icons.bookmark_outline_rounded,
  'star': Icons.star_border_rounded,
  'bell': Icons.notifications_none_rounded,
  'clock': Icons.schedule_rounded,
  'target': Icons.track_changes_rounded,
  'check': Icons.task_alt_rounded,
  'list': Icons.checklist_rounded,
  'calculator': Icons.calculate_outlined,
  'savings': Icons.savings_outlined,
  'diamond': Icons.diamond_outlined,
  'sunrise': Icons.wb_twilight_rounded,
  'boat': Icons.sailing_outlined,
  'school': Icons.school_outlined,
};
const wishIconPalettes = <String, List<Color>>{
  'indigo': [Color(0xFF172341), Color(0xFF9DACFF), Color(0xFF4D6BFE)],
  'violet': [Color(0xFF29203E), Color(0xFFD1B3FF), Color(0xFF8E61D4)],
  'mint': [Color(0xFF183739), Color(0xFFBAF3DE), Color(0xFF479D91)],
  'amber': [Color(0xFF3B2C20), Color(0xFFFFE3A6), Color(0xFFC69854)],
  'rose': [Color(0xFF3B2638), Color(0xFFF7C5DA), Color(0xFFC77CA2)],
};

/// Device emoji, semantic glyphs, or bounded vector geometry -> local PNG.
/// No external image, SVG, URL, script, or executable content is evaluated.
class WishIconArt {
  static Future<Map<String, dynamic>> render(Map<String, dynamic> value) async {
    final kind = '${value['kind'] ?? (value['emoji'] != null ? 'emoji' : 'glyph')}';
    final glyph = '${value['glyph'] ?? value['builtin'] ?? 'spark'}', palette = '${value['palette'] ?? 'indigo'}';
    final variant = (value['variant'] as num? ?? 0).toInt();
    if (!['glyph', 'emoji', 'vector'].contains(kind) ||
        !wishIconPalettes.containsKey(palette) ||
        variant < 0 ||
        variant > 2 ||
        (kind == 'glyph' && !wishIcons.containsKey(glyph))) {
      throw StateError('invalid-icon-style');
    }
    var emoji = value['emoji'];
    if (kind == 'emoji') {
      final entry = emoji is String ? (await WishEmojiCatalog.load()).entry(emoji) : null;
      if (entry == null) throw StateError('invalid-icon-emoji');
      emoji = entry.emoji;
    }
    // Validate before allocating any canvas/image resources.
    final shapes = kind == 'vector'
        ? WishIconDesigner.normalize(value)['shapes'] as List<Map<String, dynamic>>
        : <Map<String, dynamic>>[];
    final colors = wishIconPalettes[palette]!, recorder = ui.PictureRecorder();
    final draw = Canvas(recorder);
    const size = 256.0;
    const bounds = Rect.fromLTWH(0, 0, size, size);
    final tile = RRect.fromRectAndRadius(bounds, const Radius.circular(60));
    draw.clipRRect(tile);
    draw.drawRRect(
      tile,
      Paint()
        ..shader = LinearGradient(
          begin: variant == 1 ? Alignment.topRight : Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(colors[0], colors[2], .25)!, colors[0]],
        ).createShader(bounds),
    );
    draw.drawCircle(
      Offset(variant == 2 ? 194 : 56, 42),
      78,
      Paint()
        ..color = colors[2].withValues(alpha: .4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42),
    );
    final rim = RRect.fromRectAndRadius(bounds.deflate(1.5), const Radius.circular(59));
    draw.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: .36),
            colors[2].withValues(alpha: .08),
            Colors.white.withValues(alpha: .03),
          ],
        ).createShader(bounds),
    );
    TextPainter? painter;
    if (kind == 'vector') {
      draw.save();
      draw.scale(4);
      _drawShapes(draw, shapes, colors);
      draw.restore();
    } else {
      final icon = wishIcons[glyph] ?? wishIcons['spark']!;
      painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: kind == 'emoji' ? emoji as String : String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: kind == 'emoji' ? null : icon.fontFamily,
            package: kind == 'emoji' ? null : icon.fontPackage,
            fontFamilyFallback: kind == 'emoji' ? const ['Noto Color Emoji', 'Apple Color Emoji'] : null,
            fontSize: kind == 'emoji' ? 134 : 144,
            height: 1.2,
            color: colors[1],
            shadows: kind == 'emoji'
                ? null
                : [Shadow(color: colors[2].withValues(alpha: .45), blurRadius: 20, offset: const Offset(0, 6))],
          ),
        ),
      )..layout(maxWidth: 224);
      painter.paint(draw, Offset((size - painter.width) / 2, (size - painter.height) / 2 - 2));
    }
    final picture = recorder.endRecording(), image = await picture.toImage(256, 256);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    painter?.dispose();
    return {
      'bitmap': base64Encode(data!.buffer.asUint8List()),
      'builtin': kind == 'glyph' ? glyph : 'spark',
      'kind': kind,
      if (kind == 'emoji') 'emoji': emoji,
      'palette': palette,
      'variant': variant,
      'styleVersion': 2,
    };
  }

  static void _drawShapes(Canvas canvas, List<Map<String, dynamic>> shapes, List<Color> colors) {
    final roles = {'foreground': colors[1], 'accent': colors[2], 'white': Colors.white, 'background': colors[0]};
    for (final s in shapes) {
      final path = Path();
      switch (s['type']) {
        case 'circle':
          path.addOval(Rect.fromCircle(center: Offset(s['cx'] as double, s['cy'] as double), radius: s['r'] as double));
        case 'roundRect':
          path.addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(s['x'] as double, s['y'] as double, s['w'] as double, s['h'] as double),
              Radius.circular(s['r'] as double),
            ),
          );
        case 'path':
          final points = s['points'] as List;
          for (var i = 0; i < points.length; i++) {
            final p = points[i] as List;
            if (i == 0) {
              path.moveTo(p[0] as double, p[1] as double);
            } else {
              path.lineTo(p[0] as double, p[1] as double);
            }
          }
          if (s['closed'] == true) path.close();
      }
      for (final role in ['fill', 'stroke']) {
        final color = roles[s[role]];
        if (color == null) continue;
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = role == 'fill' ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = s['width'] as double
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
  }
}

String wishIconLabel(String key) => switch (key) {
  'spark' => appL10n.wishGlyphSpark,
  'timer' => appL10n.wishGlyphTimer,
  'camera' => appL10n.wishGlyphCamera,
  'assistant' => appL10n.wishGlyphAssistant,
  'trip' => appL10n.wishGlyphTrip,
  'cart' => appL10n.wishGlyphCart,
  'note' => appL10n.wishGlyphNote,
  'heart' => appL10n.wishGlyphHeart,
  'calendar' => appL10n.wishGlyphCalendar,
  'plane' => appL10n.wishGlyphPlane,
  'book' => appL10n.wishGlyphBook,
  'music' => appL10n.wishGlyphMusic,
  'weather' => appL10n.wishGlyphWeather,
  'fitness' => appL10n.wishGlyphFitness,
  'translate' => appL10n.wishGlyphTranslate,
  'code' => appL10n.wishGlyphCode,
  'receipt' => appL10n.wishGlyphReceipt,
  'globe' => appL10n.wishGlyphGlobe,
  'mail' => appL10n.wishGlyphMail,
  'chart' => appL10n.wishGlyphChart,
  'wallet' => appL10n.wishGlyphWallet,
  'home' => appL10n.wishGlyphHome,
  'work' => appL10n.wishGlyphWork,
  'search' => appL10n.wishGlyphSearch,
  'lightning' => appL10n.wishGlyphLightning,
  'leaf' => appL10n.wishGlyphLeaf,
  'coffee' => appL10n.wishGlyphCoffee,
  'restaurant' => appL10n.wishGlyphRestaurant,
  'pet' => appL10n.wishGlyphPet,
  'gift' => appL10n.wishGlyphGift,
  'photo' => appL10n.wishGlyphPhoto,
  'video' => appL10n.wishGlyphVideo,
  'headphones' => appL10n.wishGlyphHeadphones,
  'mic' => appL10n.wishGlyphMic,
  'language' => appL10n.wishGlyphLanguage,
  'map' => appL10n.wishGlyphMap,
  'compass' => appL10n.wishGlyphCompass,
  'train' => appL10n.wishGlyphTrain,
  'bike' => appL10n.wishGlyphBike,
  'car' => appL10n.wishGlyphCar,
  'walk' => appL10n.wishGlyphWalk,
  'bed' => appL10n.wishGlyphBed,
  'health' => appL10n.wishGlyphHealth,
  'brain' => appL10n.wishGlyphBrain,
  'moon' => appL10n.wishGlyphMoon,
  'cloud' => appL10n.wishGlyphCloud,
  'rain' => appL10n.wishGlyphRain,
  'water' => appL10n.wishGlyphWater,
  'flower' => appL10n.wishGlyphFlower,
  'tree' => appL10n.wishGlyphTree,
  'rocket' => appL10n.wishGlyphRocket,
  'robot' => appL10n.wishGlyphRobot,
  'game' => appL10n.wishGlyphGame,
  'paint' => appL10n.wishGlyphPaint,
  'palette' => appL10n.wishGlyphPalette,
  'pencil' => appL10n.wishGlyphPencil,
  'folder' => appL10n.wishGlyphFolder,
  'document' => appL10n.wishGlyphDocument,
  'scan' => appL10n.wishGlyphScan,
  'qr' => appL10n.wishGlyphQr,
  'lock' => appL10n.wishGlyphLock,
  'shield' => appL10n.wishGlyphShield,
  'key' => appL10n.wishGlyphKey,
  'link' => appL10n.wishGlyphLink,
  'bookmark' => appL10n.wishGlyphBookmark,
  'star' => appL10n.wishGlyphStar,
  'bell' => appL10n.wishGlyphBell,
  'clock' => appL10n.wishGlyphClock,
  'target' => appL10n.wishGlyphTarget,
  'check' => appL10n.wishGlyphCheck,
  'list' => appL10n.wishGlyphList,
  'calculator' => appL10n.wishGlyphCalculator,
  'savings' => appL10n.wishGlyphSavings,
  'diamond' => appL10n.wishGlyphDiamond,
  'sunrise' => appL10n.wishGlyphSunrise,
  'boat' => appL10n.wishGlyphBoat,
  'school' => appL10n.wishGlyphSchool,
  _ => appL10n.wishGlyphSpark,
};
