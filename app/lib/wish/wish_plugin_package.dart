import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import 'wish_package_identity.dart';
import 'wish_preset_cache.dart';

/// Public sharing uses the standard npm plugin tarball. The old JSON envelope
/// remains an internal installation protocol and a backward-compatible input.
abstract final class WishPluginPackage {
  static const maxCompressedBytes = 2000000;
  static const maxTarBytes = 2000000;
  static const maxSourceBytes = 1500000;

  static Map<String, dynamic> decode(Uint8List bytes) {
    if (bytes.length > maxCompressedBytes) throw const FormatException('release-exceeds-limit');
    if (bytes.length < 2 || bytes[0] != 0x1f || bytes[1] != 0x8b) {
      return WishPresetPackageCache.validate(utf8.decode(bytes));
    }
    final output = _BoundedSink(maxTarBytes);
    final inflater = gzip.decoder.startChunkedConversion(output);
    // Small input chunks also bound the decoder's intermediate output before
    // the receiving sink can reject a compressed expansion bomb.
    for (var offset = 0; offset < bytes.length; offset += 256) {
      inflater.add(Uint8List.sublistView(bytes, offset, (offset + 256).clamp(0, bytes.length)));
    }
    inflater.close();
    final tar = output.takeBytes();
    final headers = _checkTar(tar);
    final archive = TarDecoder().decodeBytes(tar, verify: true);
    if (archive.length != headers.length) throw const FormatException('release-invalid-file');
    final files = <Map<String, dynamic>>[];
    for (var i = 0; i < headers.length; i++) {
      final header = headers[i], file = archive.files[i];
      if (header.directory) continue;
      if (!file.isFile || file.isSymbolicLink) throw const FormatException('release-invalid-file');
      final data = Uint8List.fromList(file.content as List<int>);
      if (data.length != header.size) throw const FormatException('release-integrity-failed');
      files.add({
        'path': header.path.substring(8),
        'data': base64Encode(data),
        'sha256': sha256.convert(data).toString(),
      });
    }
    files.sort((a, b) => (a['path'] as String).compareTo(b['path'] as String));
    final package = files.where((file) => file['path'] == 'package.json').firstOrNull;
    if (package == null) throw const FormatException('release-not-portable');
    final manifest = jsonDecode(utf8.decode(base64Decode(package['data'] as String)));
    if (manifest is! Map ||
        manifest['name'] is! String ||
        !RegExp(r'^@local/local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(manifest['name'])) {
      throw const FormatException('release-not-portable');
    }
    final metadata = manifest['dshAnyApp'];
    final shared = metadata is Map && metadata['version'] == 1 ? metadata.cast<String, dynamic>() : null;
    final api = shared?['api'];
    final envelope = <String, dynamic>{
      'format': 'dsh-anyapp-plugin/1',
      'api': api is int && api >= 1 && api <= 2 ? api : 2,
      'portable': true,
      'sourceId': (manifest['name'] as String).substring(7),
      'title': 'DSH AnyApp',
      'hash': sha256.convert(utf8.encode(jsonEncode(files))).toString(),
      'files': files,
      'presentation': ?shared,
    };
    final appearance = WishPackageIdentity.resolve(envelope);
    envelope['title'] = appearance.title;
    envelope['presentation'] = {
      'version': 1,
      'title': appearance.title,
      if (appearance.icon.isNotEmpty) 'icon': appearance.icon,
    };
    return WishPresetPackageCache.validate(jsonEncode(envelope));
  }

  static Uint8List encode(Map<String, dynamic> envelope, {Map<String, dynamic> identity = const {}}) {
    WishPresetPackageCache.validate(jsonEncode(envelope));
    final appearance = WishPackageIdentity.resolve(envelope, identity: identity);
    final entries = <String, Uint8List>{};
    for (final raw in envelope['files'] as List) {
      final file = raw as Map;
      final path = file['path'] as String;
      var data = base64Decode(file['data'] as String);
      if (path == 'package.json') {
        final manifest = (jsonDecode(utf8.decode(data)) as Map).cast<String, dynamic>();
        data = Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              ...manifest,
              'dshAnyApp': {
                'version': 1,
                'title': appearance.title,
                'api': envelope['api'],
                if (appearance.icon.isNotEmpty) 'icon': appearance.icon,
              },
            }),
          ),
        );
      }
      entries['package/$path'] = data;
    }
    if (entries.values.fold<int>(0, (sum, data) => sum + data.length) > maxSourceBytes) {
      throw const FormatException('release-exceeds-limit');
    }
    final tar = _encodeTar(entries);
    if (tar.length > maxTarBytes) throw const FormatException('release-exceeds-limit');
    final encoded = Uint8List.fromList(gzip.encode(tar));
    if (encoded.length > maxCompressedBytes) throw const FormatException('release-exceeds-limit');
    return encoded;
  }

  static List<_TarEntry> _checkTar(Uint8List tar) {
    if (tar.length < 1024 || tar.length % 512 != 0) throw const FormatException('release-invalid-file');
    final result = <_TarEntry>[], names = <String>{};
    var offset = 0, sourceBytes = 0, sourceFiles = 0;
    while (offset + 512 <= tar.length) {
      final header = Uint8List.sublistView(tar, offset, offset + 512);
      if (header.every((b) => b == 0)) {
        if (offset + 1024 > tar.length || tar.skip(offset).any((b) => b != 0)) {
          throw const FormatException('release-invalid-file');
        }
        return result;
      }
      if (result.length >= 1024) throw const FormatException('release-exceeds-limit');
      final expected = _octal(header, 148, 8);
      var checksum = 0;
      for (var i = 0; i < 512; i++) {
        checksum += i >= 148 && i < 156 ? 32 : header[i];
      }
      if (checksum != expected) throw const FormatException('release-integrity-failed');
      final type = header[156];
      if (type != 0 && type != 48 && type != 53) throw const FormatException('release-invalid-file');
      if (_field(header, 157, 100).isNotEmpty) throw const FormatException('release-invalid-file');
      final prefix = _field(header, 345, 155), name = _field(header, 0, 100);
      final full = prefix.isEmpty ? name : '$prefix/$name';
      final directory = type == 53;
      final path = directory && full.endsWith('/') ? full.substring(0, full.length - 1) : full;
      if (path.isEmpty ||
          path.contains('\\') ||
          path.contains(':') ||
          RegExp(r'[\x00-\x1f\x7f]').hasMatch(path) ||
          path.split('/').any((segment) => segment.isEmpty || segment == '.' || segment == '..') ||
          (path != 'package' && !path.startsWith('package/')) ||
          !names.add(path) ||
          (!directory && path == 'package')) {
        throw const FormatException('release-invalid-file');
      }
      final size = _octal(header, 124, 12);
      if (directory && size != 0) throw const FormatException('release-invalid-file');
      if (!directory) {
        sourceBytes += size;
        if (++sourceFiles > 512 || sourceBytes > maxSourceBytes) throw const FormatException('release-exceeds-limit');
      }
      final next = offset + 512 + ((size + 511) ~/ 512) * 512;
      if (next > tar.length) throw const FormatException('release-invalid-file');
      result.add(_TarEntry(path, size, directory));
      offset = next;
    }
    throw const FormatException('release-invalid-file');
  }

  static String _field(Uint8List header, int offset, int width) {
    final bytes = Uint8List.sublistView(header, offset, offset + width);
    final end = bytes.indexOf(0);
    return utf8.decode(end < 0 ? bytes : Uint8List.sublistView(bytes, 0, end));
  }

  static int _octal(Uint8List header, int offset, int width) {
    final value = _field(header, offset, width).trim();
    if (value.isEmpty) return 0;
    if (!RegExp(r'^[0-7]+$').hasMatch(value)) throw const FormatException('release-invalid-file');
    return int.parse(value, radix: 8);
  }

  /// USTAR prefix fields keep long paths portable without PAX/GNU pseudo-files.
  static Uint8List _encodeTar(Map<String, Uint8List> files) {
    final result = BytesBuilder(copy: false);
    for (final path in (files.keys.toList()..sort())) {
      var name = path, prefix = '';
      if (utf8.encode(name).length > 100) {
        for (var split = path.lastIndexOf('/'); split > 0; split = path.lastIndexOf('/', split - 1)) {
          final candidate = path.substring(split + 1), parent = path.substring(0, split);
          if (utf8.encode(candidate).length <= 100 && utf8.encode(parent).length <= 155) {
            name = candidate;
            prefix = parent;
            break;
          }
        }
        if (prefix.isEmpty) throw const FormatException('release-invalid-file');
      }
      final data = files[path]!, header = Uint8List(512);
      void write(int offset, String value) =>
          header.setRange(offset, offset + utf8.encode(value).length, utf8.encode(value));
      void number(int offset, int width, int value) => write(offset, value.toRadixString(8).padLeft(width - 1, '0'));
      write(0, name);
      number(100, 8, 420);
      number(108, 8, 0);
      number(116, 8, 0);
      number(124, 12, data.length);
      number(136, 12, 0);
      header.fillRange(148, 156, 32);
      header[156] = 48;
      write(257, 'ustar');
      write(263, '00');
      write(345, prefix);
      final sum = header.fold<int>(0, (value, next) => value + next);
      write(148, '${sum.toRadixString(8).padLeft(6, '0')}\x00 ');
      result.add(header);
      result.add(data);
      final remainder = data.length % 512;
      if (remainder != 0) result.add(Uint8List(512 - remainder));
      if (result.length > maxTarBytes - 1024) throw const FormatException('release-exceeds-limit');
    }
    result.add(Uint8List(1024));
    return result.takeBytes();
  }
}

class _TarEntry {
  const _TarEntry(this.path, this.size, this.directory);
  final String path;
  final int size;
  final bool directory;
}

class _BoundedSink implements Sink<List<int>> {
  _BoundedSink(this.limit);
  final int limit;
  final _bytes = BytesBuilder(copy: false);
  @override
  void add(List<int> data) {
    if (_bytes.length + data.length > limit) throw const FormatException('release-exceeds-limit');
    _bytes.add(data);
  }

  @override
  void close() {}
  Uint8List takeBytes() => _bytes.takeBytes();
}
