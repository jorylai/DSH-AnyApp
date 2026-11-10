import 'package:flutter/material.dart';

import 'wish_palette.dart';
import 'wish_dot_motion.dart';
import 'wish_motion.dart';

/// A restrained raised action, with a stable focus target and reduced-motion support.
class WishRitualButton extends StatefulWidget {
  const WishRitualButton({super.key, required this.label, required this.onPressed, this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  @override
  State<WishRitualButton> createState() => _RitualButtonState();
}

class _RitualButtonState extends State<WishRitualButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? widget.onPressed : null,
      excludeSemantics: true,
      child: WishPressable(
        enabled: enabled,
        child: AnimatedContainer(
          duration: WishMotion.duration(context, WishMotion.quick),
          curve: WishMotion.settle,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled
                  ? [const Color(0xFF788AFF), wishBlue, const Color(0xFF4357D3)]
                  : [const Color(0xFF39446B), const Color(0xFF273252)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: enabled ? .25 : .08)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: wishBlue.withValues(alpha: _pressed ? .12 : .23),
                      blurRadius: _pressed ? 12 : 24,
                      offset: Offset(0, _pressed ? 2 : 8),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              excludeFromSemantics: true,
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: WishContentTransition(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.label,
                          key: ValueKey(widget.label),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox.square(
                      dimension: 24,
                      child: WishContentTransition(
                        child: widget.busy
                            ? const WishDotLoader(key: ValueKey('busy'), size: 24)
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                key: ValueKey('ready'),
                                size: 21,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WishBrandMark extends StatelessWidget {
  const WishBrandMark({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * .24),
      boxShadow: [
        BoxShadow(color: wishBlue.withValues(alpha: .2), blurRadius: size * .6, offset: Offset(0, size * .1)),
      ],
    ),
    child: Image.asset('assets/brand/mark.png', filterQuality: FilterQuality.high),
  );
}

/// A restrained folded-window motif. Its geometry belongs to AnyApp; no third-party mascot.
class WishSeedArtwork extends StatelessWidget {
  const WishSeedArtwork({super.key, this.size = 200});
  final double size;
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: const _SeedPainter());
}

class _SeedPainter extends CustomPainter {
  const _SeedPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200;
    canvas.save();
    canvas.scale(s);
    canvas.drawCircle(
      const Offset(132, 69),
      96,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0x50556DFF), Color(0x004D6BFE)])
            .createShader(const Rect.fromLTWH(36, -27, 192, 192)),
    );
    canvas.save();
    canvas.translate(105, 90);
    canvas.rotate(-.22);
    final shape = RRect.fromRectAndRadius(const Rect.fromLTWH(-49, -49, 98, 98), const Radius.circular(25));
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x205A75FF), Color(0x045A75FF)],
        ).createShader(shape.outerRect),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x405F7BFC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -32, 64, 64), const Radius.circular(18)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x309CD6CD),
    );
    canvas.drawLine(
      const Offset(-18, 0),
      const Offset(18, 0),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x70B8C6FF),
    );
    canvas.drawLine(
      const Offset(0, -18),
      const Offset(0, 18),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x70B8C6FF),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(160, 37), 5, Paint()..color = const Color(0x909DDACC));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeedPainter oldDelegate) => false;
}
