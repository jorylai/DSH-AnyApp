import 'dart:convert';
import 'dart:typed_data';

import 'package:xml/xml.dart';

import 'wish_icon_art.dart';

/// Appearance travels separately from source files, records and account state.
/// Legacy bundles expose their name through data files, never executable code.
class WishPackageIdentity {
  const WishPackageIdentity({required this.title, this.icon = const {}});
  final String title;
  final Map<String, dynamic> icon;

  static WishPackageIdentity resolve(Map<String, dynamic> envelope, {Map<String, dynamic>? identity}) {
    final presentation = envelope['presentation'];
    final shared = presentation is Map && presentation['version'] == 1 ? presentation : const {};
    final files = _files(envelope);
    final manifest = _json(files['package.json']);
    String? legacyTitle;
    for (final name in ['zh', 'zh_CN', 'zh-CN', 'zh-Hans', 'en', 'en_US', 'en-US']) {
      for (final folder in ['locale', 'i18n']) {
        final locale = _json(files['$folder/$name.json']);
        final meta = locale['meta'];
        legacyTitle ??= meta is Map ? _name(meta['title']) : null;
      }
    }
    final title =
        _name(identity?['customName']) ??
        _name(identity?['title']) ??
        _name(shared['title']) ??
        legacyTitle ??
        _name(manifest['displayName']) ??
        _shortName(envelope['title']) ??
        _descriptionName(manifest['description']) ??
        _descriptionName(envelope['title']) ??
        'DSH AnyApp';
    final icon =
        sanitizeIcon(identity?['icon']) ??
        sanitizeIcon(identity?['declaredIcon']) ??
        sanitizeIcon(shared['icon']) ??
        _fileIcon(files, manifest) ??
        <String, dynamic>{};
    return WishPackageIdentity(title: title, icon: icon);
  }

  /// The file checksum remains intact: presentation is an additive envelope
  /// field. No private work ID, custom actions or record data is exported here.
  static Map<String, dynamic> attach(Map<String, dynamic> envelope, {required Map<String, dynamic> identity}) {
    final resolved = resolve(envelope, identity: identity);
    return {
      ...envelope,
      'title': resolved.title,
      'presentation': {'version': 1, 'title': resolved.title, if (resolved.icon.isNotEmpty) 'icon': resolved.icon},
    };
  }

  static String? _name(Object? value) {
    if (value is! String) return null;
    final text = value.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty || text.length > 80) return null;
    return text;
  }

  // A declared short app name is more specific than a descriptive sentence.
  // Long legacy titles were often creation prompts; locale metadata above
  // still takes precedence so those bundles recover their actual app name.
  static String? _shortName(Object? value) {
    final text = _name(value);
    return text != null && text.length <= 32 ? text : null;
  }

  static String? _descriptionName(Object? value) {
    if (value is! String) return null;
    final first = value.trim().split(RegExp(r'[\n\r：:；;。.!！?？]')).first.trim();
    if (first.isEmpty) return null;
    final text = _name(first.length > 32 ? '${first.substring(0, 31).trimRight()}…' : first);
    return text;
  }

  static Map<String, String> _files(Map<String, dynamic> envelope) => {
    for (final file in (envelope['files'] as List? ?? const []).take(512))
      if (file is Map && file['path'] is String && file['data'] is String)
        file['path'] as String: file['data'] as String,
  };

  static Map<String, dynamic> _json(String? encoded) {
    if (encoded == null || encoded.length > 180000) return {};
    try {
      final value = jsonDecode(utf8.decode(base64Decode(encoded)));
      return value is Map ? value.cast<String, dynamic>() : {};
    } catch (_) {
      return {};
    }
  }

  static Map<String, dynamic>? _fileIcon(Map<String, String> files, Map<String, dynamic> manifest) {
    final exports = manifest['exports'];
    final exported = exports is Map ? exports['./icon'] : null;
    final candidates = [
      if (exported is String && exported.startsWith('./')) exported.substring(2),
      'icon.png',
      'icon.svg',
      'assets/icon.png',
      'assets/icon.svg',
    ];
    for (final path in candidates) {
      final value = files[path];
      if (value == null || value.length > 350000) continue;
      if (path.endsWith('.png')) {
        final icon = sanitizeIcon({'bitmap': value});
        if (icon != null) return icon;
      }
      if (path.endsWith('.svg') && value.length <= 44000) {
        try {
          final svg = sanitizeSvg(utf8.decode(base64Decode(value)));
          if (svg != null) return {'svg': svg};
        } catch (_) {
          // A broken optional icon must not make a portable app unusable.
        }
      }
    }
    return null;
  }

  static Map<String, dynamic>? sanitizeIcon(Object? raw) {
    if (raw is! Map) return null;
    if (raw['bitmap'] is String) {
      final value = raw['bitmap'] as String;
      if (value.length > 350000) return null;
      try {
        final bytes = base64Decode(value);
        const signature = [137, 80, 78, 71, 13, 10, 26, 10];
        if (bytes.length < 33 || !List.generate(8, (i) => bytes[i] == signature[i]).every((v) => v)) return null;
        final header = ByteData.sublistView(bytes);
        final width = header.getUint32(16), height = header.getUint32(20);
        if (width < 64 || width > 512 || width != height) return null;
        final kind = raw['kind'];
        return {
          'bitmap': value,
          if (kind is String && ['glyph', 'builtin', 'emoji', 'vector'].contains(kind)) 'kind': kind,
          if (kind == 'emoji' && raw['emoji'] is String && (raw['emoji'] as String).length <= 64) 'emoji': raw['emoji'],
          if (raw['builtin'] is String && wishIcons.containsKey(raw['builtin'])) 'builtin': raw['builtin'],
          if (raw['palette'] is String && wishIconPalettes.containsKey(raw['palette'])) 'palette': raw['palette'],
          if (raw['variant'] is int && raw['variant'] >= 0 && raw['variant'] <= 2) 'variant': raw['variant'],
          if (raw['styleVersion'] is int && raw['styleVersion'] >= 1 && raw['styleVersion'] <= 2)
            'styleVersion': raw['styleVersion'],
        };
      } catch (_) {
        return null;
      }
    }
    if (raw['svg'] is String) {
      final svg = sanitizeSvg(raw['svg'] as String);
      return svg == null ? null : {'svg': svg};
    }
    if (raw['builtin'] is String && wishIcons.containsKey(raw['builtin'])) return {'builtin': raw['builtin']};
    final paths = raw['paths'];
    final color = RegExp(r'^#[0-9a-fA-F]{6}$');
    if (paths is! List ||
        paths.isEmpty ||
        paths.length > 16 ||
        !color.hasMatch('${raw['background']}') ||
        !color.hasMatch('${raw['color']}')) {
      return null;
    }
    final safe = <Map<String, dynamic>>[];
    for (final path in paths) {
      if (path is! Map || path['points'] is! List) return null;
      final points = path['points'] as List;
      if (points.length < 2 || points.length > 96) return null;
      final converted = <List<double>>[];
      for (final point in points) {
        if (point is! List || point.length != 2 || point.any((n) => n is! num || !n.isFinite || n < 0 || n > 64)) {
          return null;
        }
        converted.add(point.map((n) => (n as num).toDouble()).toList());
      }
      final width = path['width'] ?? 3;
      if (width is! num || !width.isFinite || width < 1 || width > 8) return null;
      safe.add({
        'points': converted,
        'width': width,
        'closed': path['closed'] == true,
        'filled': path['filled'] == true,
      });
    }
    return {'background': raw['background'], 'color': raw['color'], 'paths': safe};
  }

  /// A small static SVG subset. Scripts, external resources, CSS, animation,
  /// entity declarations and interaction attributes never reach the renderer.
  static String? sanitizeSvg(String source) {
    if (utf8.encode(source).length > 32768 || source.contains('<!')) return null;
    try {
      final document = XmlDocument.parse(source);
      final root = document.rootElement;
      if (root.name.qualified != 'svg') return null;
      const elements = {
        'svg',
        'g',
        'defs',
        'linearGradient',
        'radialGradient',
        'stop',
        'rect',
        'circle',
        'ellipse',
        'path',
        'line',
        'polyline',
        'polygon',
        'clipPath',
        'mask',
        'title',
        'desc',
      };
      const attributes = {
        'xmlns',
        'viewBox',
        'width',
        'height',
        'x',
        'y',
        'x1',
        'x2',
        'y1',
        'y2',
        'cx',
        'cy',
        'r',
        'rx',
        'ry',
        'fx',
        'fy',
        'id',
        'fill',
        'stroke',
        'fill-opacity',
        'stroke-opacity',
        'opacity',
        'stroke-width',
        'stroke-linecap',
        'stroke-linejoin',
        'stroke-miterlimit',
        'stroke-dasharray',
        'stroke-dashoffset',
        'fill-rule',
        'clip-rule',
        'd',
        'points',
        'transform',
        'gradientTransform',
        'gradientUnits',
        'offset',
        'stop-color',
        'stop-opacity',
        'clip-path',
        'mask',
        'preserveAspectRatio',
        'role',
        'aria-label',
      };
      var count = 0;
      bool check(XmlElement element, int depth) {
        if (++count > 192 ||
            depth > 16 ||
            !elements.contains(element.name.qualified) ||
            element.attributes.length > 24) {
          return false;
        }
        for (final attr in element.attributes) {
          final key = attr.name.qualified, value = attr.value;
          if (!attributes.contains(key) || value.length > 4096) return false;
          if (key == 'xmlns') {
            if (element != root || value != 'http://www.w3.org/2000/svg') return false;
          } else if (key == 'id') {
            if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_-]{0,63}$').hasMatch(value)) return false;
          } else if (key == 'role' || key == 'aria-label') {
            if (value.length > 96) return false;
          } else {
            if (RegExp(r'url\s*\(', caseSensitive: false).hasMatch(value) &&
                !RegExp(r'^url\(#[A-Za-z_][A-Za-z0-9_-]{0,63}\)$').hasMatch(value)) {
              return false;
            }
            if (RegExp(r'[<>:;/&]|(?:https?|data|javascript)\s*:', caseSensitive: false).hasMatch(value)) return false;
          }
        }
        for (final node in element.children) {
          if (node is XmlElement) {
            if (!check(node, depth + 1)) return false;
          } else if (node is XmlText) {
            if (node.value.trim().isNotEmpty && !{'title', 'desc'}.contains(element.name.qualified)) return false;
          } else if (node is! XmlComment) {
            return false;
          }
        }
        return true;
      }

      if (!check(root, 0)) return null;
      if (document.children.any((node) => node is XmlProcessing || node is XmlDoctype)) return null;
      return root.toXmlString();
    } catch (_) {
      return null;
    }
  }
}
