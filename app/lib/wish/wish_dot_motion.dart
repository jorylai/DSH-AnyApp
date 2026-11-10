import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'wish_palette.dart';

/// An indeterminate waiting motif. [phase] is an accessibility announcement;
/// callers keep the actual, localized stage text next to the graphic.
class WishDotLoader extends StatelessWidget {
  const WishDotLoader({super.key, this.size = 72, this.phase}) : assert(size > 0);

  final double size;
  final String? phase;

  @override
  Widget build(BuildContext context) => _WishDotMotion(size: size, loader: true, active: true, phase: phase);
}

/// The original AnyApp constellation: warm light, blue points and one mint seed.
/// Set [active] false for static decoration or a page that is no longer visible.
class WishDotMark extends StatelessWidget {
  const WishDotMark({super.key, this.size = 64, this.active = true}) : assert(size > 0);

  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) => _WishDotMotion(size: size, loader: false, active: active);
}

class _WishDotMotion extends StatefulWidget {
  const _WishDotMotion({required this.size, required this.loader, required this.active, this.phase});

  final double size;
  final bool loader, active;
  final String? phase;

  @override
  State<_WishDotMotion> createState() => _WishDotMotionState();
}

class _WishDotMotionState extends State<_WishDotMotion> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion;
  bool _reduced = true, _visible = true, _resumed = true;

  bool get _canAnimate => widget.active && !_reduced && _visible && _resumed;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance;
    _resumed = binding.lifecycleState == null || binding.lifecycleState == AppLifecycleState.resumed;
    binding.addObserver(this);
    _motion = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.loader ? 2400 : 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _visible = TickerMode.valuesOf(context).enabled;
    _syncMotion();
  }

  @override
  void didUpdateWidget(_WishDotMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (_resumed == resumed) return;
    setState(() => _resumed = resumed);
    _syncMotion();
  }

  void _syncMotion() {
    if (_canAnimate) {
      if (!_motion.isAnimating) {
        if (widget.loader) {
          _motion.repeat();
        } else if (!_motion.isCompleted) {
          _motion.forward();
        }
      }
    } else {
      _motion.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphic = IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: _WishDotPainter(motion: _motion, loader: widget.loader, animated: _canAnimate),
          ),
        ),
      ),
    );
    final phase = widget.phase;
    return phase == null || phase.isEmpty
        ? ExcludeSemantics(child: graphic)
        : Semantics(label: phase, liveRegion: true, child: graphic);
  }
}

class _WishDotPainter extends CustomPainter {
  _WishDotPainter({required this.motion, required this.loader, required this.animated}) : super(repaint: motion);

  final Animation<double> motion;
  final bool loader, animated;

  static const _anchors = <Offset>[
    Offset(-.26, -.035),
    Offset(-.15, -.245),
    Offset(.075, -.27),
    Offset(.265, -.105),
    Offset(.23, .12),
    Offset(.025, .265),
    Offset(-.205, .19),
  ];
  static const _radii = <double>[.032, .038, .032, .047, .034, .038, .03];
  static const _colors = <Color>[
    Color(0xFF7390FF),
    Color(0xFFB4C2FF),
    wishBlue,
    wishGreen,
    Color(0xFF7291FF),
    Color(0xFFD7DEFF),
    wishBlue,
  ];

  static double _smooth(double start, double end, double t) {
    final value = ((t - start) / (end - start)).clamp(0.0, 1.0);
    return value * value * (3 - 2 * value);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height);
    final center = size.center(Offset.zero);
    final t = animated ? motion.value : .18;
    final angle = t * math.pi * 2;
    final breath = animated ? math.sin(angle) : 0.0;
    final gather = loader && animated ? _smooth(.27, .50, t) * (1 - _smooth(.70, .95, t)) : 0.0;
    final positions = <Offset>[];

    for (var i = 0; i < _anchors.length; i++) {
      final seed = i * math.pi * 2 / _anchors.length - math.pi / 2;
      final anchor = _anchors[i];
      Offset point;
      if (loader && animated) {
        final orbit = seed + angle;
        final spread = Offset(math.cos(orbit) * .31, math.sin(orbit) * .285);
        final gathered = Offset(math.cos(seed + .15) * .135, math.sin(seed + .15) * .135);
        point = Offset.lerp(spread, gathered, gather)!;
      } else {
        final drift = animated ? math.sin(angle + seed) * .013 : 0.0;
        final settle = animated ? Curves.easeOutCubic.transform(t) : 1.0;
        point = anchor * (1.65 - .65 * settle) + Offset(drift * (1 - settle), drift * -.65 * (1 - settle));
      }
      positions.add(center + point * scale);
    }

    // A broad, very faint wash and solid translucent circles replace blur filters.
    final washRadius = scale * (.30 + breath * .012);
    canvas.drawCircle(center, washRadius, Paint()..color = wishBlue.withValues(alpha: .025));
    canvas.drawCircle(center, scale * .19, Paint()..color = wishBlue.withValues(alpha: .035 + gather * .025));

    // Quiet threads make the resting form read as a constellation, not a spinner.
    final thread = Paint()
      ..color = const Color(0xFF8BA2FF).withValues(alpha: .10 - gather * .04)
      ..strokeWidth = math.max(.5, scale * .006)
      ..style = PaintingStyle.stroke;
    for (final i in const [0, 2, 4, 6]) {
      canvas.drawLine(center, positions[i], thread);
    }

    for (var i = 0; i < positions.length; i++) {
      final shimmer = animated ? .5 + .5 * math.sin(angle + i * .8) : .5;
      final radius = scale * _radii[i] * (1 + shimmer * .075);
      final color = _colors[i];
      canvas.drawCircle(positions[i], radius * 2.1, Paint()..color = color.withValues(alpha: .045));
      canvas.drawCircle(positions[i], radius * 1.40, Paint()..color = color.withValues(alpha: .09));
      canvas.drawCircle(positions[i], radius, Paint()..color = color.withValues(alpha: .78 + shimmer * .20));
      canvas.drawCircle(
        positions[i] - Offset(radius * .18, radius * .22),
        radius * .29,
        Paint()..color = wishText.withValues(alpha: i == 3 ? .50 : .30),
      );
    }

    final coreRadius = scale * (.058 + gather * .012 + breath * .002);
    canvas.drawCircle(center, coreRadius * 2.4, Paint()..color = wishText.withValues(alpha: .025 + gather * .02));
    canvas.drawCircle(center, coreRadius * 1.45, Paint()..color = wishText.withValues(alpha: .065));
    canvas.drawCircle(center, coreRadius, Paint()..color = wishText);
  }

  @override
  bool shouldRepaint(_WishDotPainter oldDelegate) =>
      motion != oldDelegate.motion || loader != oldDelegate.loader || animated != oldDelegate.animated;
}
