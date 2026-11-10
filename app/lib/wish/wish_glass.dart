import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'wish_palette.dart';

/// One light field for a whole page. Scroll changes paint only, never layout.
/// No ticker or sensor is used; a resting/offstage page consumes no frames.
class WishGlassScene extends StatefulWidget {
  const WishGlassScene({super.key, required this.child});
  final Widget child;
  @override
  State<WishGlassScene> createState() => _WishGlassSceneState();
}

class _WishGlassSceneState extends State<WishGlassScene> {
  final _light = ValueNotifier<double>(0);
  @override
  void dispose() {
    _light.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return _GlassLight(
      light: _light,
      child: BackdropGroup(
        child: NotificationListener<ScrollNotification>(
          onNotification: (event) {
            if (!reduced && event.depth == 0 && event.metrics.axis == Axis.vertical) {
              _light.value = event.metrics.pixels.clamp(-120.0, 6000.0);
            }
            return false;
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _GlassField(_light, reduced: reduced)),
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassLight extends InheritedWidget {
  const _GlassLight({required this.light, required super.child});
  final ValueNotifier<double> light;
  @override
  bool updateShouldNotify(_GlassLight oldWidget) => light != oldWidget.light;
}

/// A clipped translucent lens: shared backdrop blur, soft sheen and a hairline rim.
/// Content remains opaque and motionless so the effect never reduces legibility.
class WishGlassSurface extends StatelessWidget {
  const WishGlassSurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.tint = const Color(0xFF7B99F0),
    this.seed = 0,
    this.emphasis = false,
  });
  final Widget child;
  final double radius, seed;
  final Color tint;
  final bool emphasis;
  @override
  Widget build(BuildContext context) {
    final light = context.dependOnInheritedWidgetOfExactType<_GlassLight>()?.light;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final contrast = MediaQuery.highContrastOf(context);
    final content = CustomPaint(
      painter: _GlassLens(
        light,
        tint: tint,
        radius: radius,
        seed: seed,
        reduced: reduced,
        opaque: contrast,
        emphasis: emphasis,
      ),
      foregroundPainter: _GlassRim(light, tint: tint, radius: radius, seed: seed, reduced: reduced, emphasis: emphasis),
      child: child,
    );
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: contrast
            ? content
            : BackdropFilter.grouped(filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7), child: content),
      ),
    );
  }
}

class _GlassField extends CustomPainter {
  _GlassField(this.light, {required this.reduced}) : super(repaint: reduced ? null : light);
  final ValueListenable<double> light;
  final bool reduced;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = wishBg);
    final t = reduced ? 0.0 : light.value / 1100;
    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    glow(
      Offset(size.width * (.82 + .12 * math.sin(t)), size.height * (.15 - .08 * math.sin(t))),
      size.width * .85,
      const Color(0x3D536BC8),
    );
    glow(
      Offset(size.width * (.08 + .15 * math.sin(t * .7)), size.height * .58),
      size.width * .67,
      const Color(0x223E9D9A),
    );
    glow(Offset(size.width * .86, size.height * (.93 + .08 * math.cos(t))), size.width * .8, const Color(0x247665C7));
  }

  @override
  bool shouldRepaint(_GlassField old) => reduced != old.reduced || light != old.light;
}

class _GlassLens extends CustomPainter {
  _GlassLens(
    this.light, {
    required this.tint,
    required this.radius,
    required this.seed,
    required this.reduced,
    required this.opaque,
    required this.emphasis,
  }) : super(repaint: reduced ? null : light);
  final ValueListenable<double>? light;
  final Color tint;
  final double radius, seed;
  final bool reduced, opaque, emphasis;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = (reduced ? 0 : (light?.value ?? 0) / 650) + seed;
    final x = .1 + .75 * (.5 + .5 * math.sin(t));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: opaque
              ? [wishSurfaceAlt, wishSurface]
              : [
                  const Color(0xFF20314D).withValues(alpha: emphasis ? .64 : .50),
                  const Color(0xFF111C30).withValues(alpha: .76),
                ],
        ).createShader(rect),
    );
    if (opaque) return;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(x * 2 - 1, -.95),
          radius: 1.25,
          colors: [
            tint.withValues(alpha: emphasis ? .17 : .10),
            tint.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
    // The broad curved reflection moves with scroll and stays below the text.
    final ribbon = Path()
      ..moveTo(size.width * (x - .85), 0)
      ..cubicTo(
        size.width * (x - .35),
        size.height * .35,
        size.width * (x + .2),
        size.height * .12,
        size.width * (x + .65),
        size.height,
      )
      ..lineTo(size.width * (x + .82), size.height)
      ..cubicTo(
        size.width * (x + .32),
        size.height * .06,
        size.width * (x - .2),
        size.height * .18,
        size.width * (x - .7),
        0,
      )
      ..close();
    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x05FFFFFF), Color(0x08D1E9FF), Color(0x00FFFFFF)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassLens old) =>
      old.light != light ||
      old.tint != tint ||
      old.radius != radius ||
      old.seed != seed ||
      old.reduced != reduced ||
      old.opaque != opaque ||
      old.emphasis != emphasis;
}

class _GlassRim extends CustomPainter {
  _GlassRim(
    this.light, {
    required this.tint,
    required this.radius,
    required this.seed,
    required this.reduced,
    required this.emphasis,
  }) : super(repaint: reduced ? null : light);
  final ValueListenable<double>? light;
  final Color tint;
  final double radius, seed;
  final bool reduced, emphasis;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(.65);
    final t = (reduced ? 0 : (light?.value ?? 0) / 650) + seed;
    final shift = math.sin(t) * .65;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..shader = LinearGradient(
          begin: Alignment(-.85 + shift, -1),
          end: Alignment(.9, 1),
          colors: [
            const Color(0x58ECF5FF),
            tint.withValues(alpha: .17),
            const Color(0x08FFFFFF),
            tint.withValues(alpha: emphasis ? .32 : .18),
          ],
          stops: const [0, .27, .66, 1],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), Radius.circular((radius - 2).clamp(0, radius))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .65
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0x12FFFFFF)],
          stops: [0, .72, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassRim old) =>
      old.light != light ||
      old.tint != tint ||
      old.radius != radius ||
      old.seed != seed ||
      old.reduced != reduced ||
      old.emphasis != emphasis;
}
