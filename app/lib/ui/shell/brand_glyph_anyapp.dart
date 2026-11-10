import 'dart:ui' as ui;
import 'dart:ui' show Color, Offset, Path, Radius, Rect, RRect, Shader;

/// Original AnyApp app-window mark. Legacy field names keep theme callers compatible.
abstract final class BrandGlyph {
  static const box = Rect.fromLTRB(26, 22, 86, 84);
  static const aspect = 60 / 62;
  static const centroid = Offset(56.5, 53);
  static const tileBox = Rect.fromLTWH(18, 18, 72, 72);
  static final tile = Path()..addRRect(RRect.fromRectAndRadius(tileBox, const Radius.circular(20)));
  static final body = Path()
    ..fillType = ui.PathFillType.evenOdd
    ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(31, 30, 48, 48), const Radius.circular(13)))
    ..moveTo(52, 42)
    ..lineTo(57, 42)
    ..lineTo(57, 52)
    ..lineTo(67, 52)
    ..lineTo(67, 57)
    ..lineTo(57, 57)
    ..lineTo(57, 67)
    ..lineTo(52, 67)
    ..lineTo(52, 57)
    ..lineTo(42, 57)
    ..lineTo(42, 52)
    ..lineTo(52, 52)
    ..close();
  static final fin = Path()
    ..moveTo(29, 41)
    ..lineTo(29, 72)
    ..quadraticBezierTo(29, 81, 39, 81)
    ..lineTo(67, 81)
    ..lineTo(67, 84)
    ..lineTo(38, 84)
    ..quadraticBezierTo(26, 84, 26, 72)
    ..lineTo(26, 41)
    ..close();
  static final belly = Path();
  static final bubble = Path()
    ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(74, 22, 12, 12), const Radius.circular(4)));
  static Shader _gradient(Color a, Color b) => ui.Gradient.linear(const Offset(28, 24), const Offset(80, 84), [a, b]);
  static final tileFill = _gradient(const Color(0xFF233353), const Color(0xFF0C1527));
  static final tailLight = _gradient(const Color(0xFF879AFF), const Color(0xFF526BE8));
  static final tailDark = _gradient(const Color(0xFFBBC8FF), const Color(0xFF7188FA));
  static final finLight = _gradient(const Color(0xFF7185CA), const Color(0xFF526BE8));
  static final finDark = finLight;
  static final bellyLight = tailLight;
  static final bellyDark = tailDark;
  static final bubbleLight = _gradient(const Color(0xFFA7E6D7), const Color(0xFF6BBBA8));
  static final bubbleDark = bubbleLight;
}
