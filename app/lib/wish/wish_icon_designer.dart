import 'dart:convert';

/// A text model designs shapes; only the local renderer produces pixels.
/// Neither model responses nor work descriptions can select a network endpoint.
class WishIconDesigner {
  static const palettes = {'indigo', 'violet', 'mint', 'amber', 'rose'};
  static const colorRoles = {'foreground', 'accent', 'white', 'background', 'none'};
  static const maxShapes = 16;
  static const maxPoints = 96;

  static String prompt({
    required String name,
    required String purpose,
    String request = '',
    Map<String, dynamic>? previous,
  }) {
    final context = <String, dynamic>{
      'name': _limit(name, 80),
      'purpose': _limit(purpose, 600),
      'designRequest': _limit(request, 400),
    };
    if (previous?['kind'] == 'vector') {
      try {
        context['previousDesign'] = normalize({
          for (final key in ['kind', 'palette', 'variant', 'shapes'])
            if (previous!.containsKey(key)) key: previous[key],
        });
      } on FormatException {
        // A legacy icon is not a constraint on a new design.
      }
    }
    return '''You are designing an original, elegant app icon for DSH AnyApp.
Use the context below only to understand the app and the user's visual preference.
Create an original geometric symbol, not a selection from an existing icon list.
Use a bold, distinctive silhouette, balanced negative space, 3–8 useful layered
shapes, and enough contrast to read at 32px. Keep the subject inside 8..56 on a
64 by 64 canvas. The host already draws a rounded gradient tile and subtle glow;
do not add a full-canvas background rectangle. No text, letters, brand logos,
photography, URLs, SVG, executable code, or API instructions. If a previous design
is provided, vary its composition, not merely its color. If no visual request is
provided, infer a suitable metaphor from the app purpose.

Return exactly one JSON object, optionally fenced with json, and no explanation:
{"kind":"vector","palette":"mint","variant":0,"shapes":[
 {"type":"circle","cx":32,"cy":30,"r":15,"fill":"foreground"},
 {"type":"roundRect","x":29,"y":17,"w":6,"h":17,"r":3,"fill":"background"},
 {"type":"path","points":[[24,42],[32,48],[40,42]],"closed":false,"fill":"none","stroke":"accent","width":3}
]}
This example illustrates the schema only; invent a composition for this app.
Allowed palettes: indigo, violet, mint, amber, rose. variant: integer 0, 1 or 2.
Shapes: circle (cx,cy,r), roundRect (x,y,w,h,r), path (points,closed).
All coordinates must be finite numbers. Path points and circle/rectangle extents
must stay in 2..62, retaining edge clearance. Radius, width and height must be at
least 1; a roundRect may have r=0, at most half its smaller side.
At most 16 shapes and 96 path points total. Path needs at least 2 points; filled
paths must be closed and have at least 3 points. No path command strings.
fill/stroke use only foreground, accent, white, background, none. Each shape must
have a visible fill or stroke. Stroke width is 0.5..6. Rounded caps/joins are
provided by the host. Do not add fields beyond this schema.

App context JSON:
${jsonEncode(context)}''';
  }

  static Map<String, dynamic> parse(String response) {
    if (response.length > 32768) _invalid();
    var text = response.trim();
    if (text.startsWith('```')) {
      final fenced = RegExp(r'^```(?:json)?\s*\n?([\s\S]*?)\n?```$', caseSensitive: false).firstMatch(text);
      if (fenced == null) _invalid();
      text = fenced.group(1)!.trim();
    }
    dynamic value;
    try {
      value = jsonDecode(text);
    } on FormatException {
      _invalid();
    }
    if (value is! Map<String, dynamic>) _invalid();
    return normalize(value);
  }

  /// Re-validates styles passed through the public render bridge as well as AI.
  static Map<String, dynamic> normalize(Map<String, dynamic> value) {
    _keys(value, {'kind', 'palette', 'variant', 'shapes'});
    if (value['kind'] != 'vector' || !palettes.contains(value['palette'])) _invalid();
    final variant = value['variant'];
    if (variant is! int || variant < 0 || variant > 2) _invalid();
    final rawShapes = value['shapes'];
    if (rawShapes is! List || rawShapes.isEmpty || rawShapes.length > maxShapes) _invalid();
    var pointsUsed = 0;
    final shapes = <Map<String, dynamic>>[];
    for (final raw in rawShapes) {
      if (raw is! Map<String, dynamic>) _invalid();
      final shape = raw;
      final type = shape['type'];
      final fill = shape['fill'] ?? (type == 'path' ? 'none' : 'foreground');
      final stroke = shape['stroke'] ?? 'none';
      if (!colorRoles.contains(fill) || !colorRoles.contains(stroke) || (fill == 'none' && stroke == 'none')) {
        _invalid();
      }
      final width = _number(shape['width'] ?? 2.5, min: .5, max: 6);
      final result = <String, dynamic>{'type': type, 'fill': fill, 'stroke': stroke, 'width': width};
      switch (type) {
        case 'circle':
          _keys(shape, {'type', 'cx', 'cy', 'r', 'fill', 'stroke', 'width'});
          final cx = _number(shape['cx']);
          final cy = _number(shape['cy']);
          final r = _number(shape['r'], min: 1, max: 30);
          if (cx - r < 2 || cy - r < 2 || cx + r > 62 || cy + r > 62) _invalid();
          result.addAll({'cx': cx, 'cy': cy, 'r': r});
        case 'roundRect':
          _keys(shape, {'type', 'x', 'y', 'w', 'h', 'r', 'fill', 'stroke', 'width'});
          final x = _number(shape['x'], min: 2, max: 62);
          final y = _number(shape['y'], min: 2, max: 62);
          final w = _number(shape['w'], min: 1);
          final h = _number(shape['h'], min: 1);
          final r = _number(shape['r']);
          if (x + w > 62 || y + h > 62 || r > w / 2 || r > h / 2) _invalid();
          result.addAll({'x': x, 'y': y, 'w': w, 'h': h, 'r': r});
        case 'path':
          _keys(shape, {'type', 'points', 'closed', 'fill', 'stroke', 'width'});
          final points = shape['points'];
          final closed = shape['closed'] ?? false;
          if (points is! List || points.length < 2 || closed is! bool) _invalid();
          pointsUsed += points.length;
          if (pointsUsed > maxPoints || (fill != 'none' && (closed != true || points.length < 3))) _invalid();
          final normalizedPoints = <List<double>>[];
          for (final point in points) {
            if (point is! List || point.length != 2) _invalid();
            normalizedPoints.add([_number(point[0], min: 2, max: 62), _number(point[1], min: 2, max: 62)]);
          }
          result.addAll({'points': normalizedPoints, 'closed': closed});
        default:
          _invalid();
      }
      shapes.add(result);
    }
    return {'kind': 'vector', 'palette': value['palette'], 'variant': variant, 'shapes': shapes};
  }

  static String _limit(String value, int max) => String.fromCharCodes(value.runes.take(max));

  static void _keys(Map<String, dynamic> value, Set<String> allowed) {
    if (value.keys.any((key) => !allowed.contains(key))) _invalid();
  }

  static double _number(dynamic value, {double min = 0, double max = 64}) {
    if (value is! num || !value.isFinite || value < min || value > max) _invalid();
    return value.toDouble();
  }

  static Never _invalid() => throw const FormatException('ICON_DESIGN_INVALID');
}
