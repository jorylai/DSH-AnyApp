import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dsh_app/wish/wish_package_identity.dart';
import 'package:dsh_app/wish/wish_plugin_package.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> envelope({Map<String, String> extra = const {}}) {
  final source = {
    'package.json': '{"name":"@local/local-share-test","version":"1.0.0","type":"module","exports":{".":"./index.js"}}',
    'index.js': 'export default class Plugin {}',
    'locale/zh.json': '{"meta":{"title":"分享清单"}}',
    ...extra,
  };
  final files = [
    for (final path in (source.keys.toList()..sort()))
      {
        'path': path,
        'data': base64Encode(utf8.encode(source[path]!)),
        'sha256': sha256.convert(utf8.encode(source[path]!)).toString(),
      },
  ];
  return {
    'format': 'dsh-anyapp-plugin/1',
    'portable': true,
    'api': 2,
    'sourceId': 'local-share-test',
    'title': 'Make an app that keeps my notes',
    'hash': sha256.convert(utf8.encode(jsonEncode(files))).toString(),
    'files': files,
  };
}

Uint8List tarball(Archive archive) => Uint8List.fromList(gzip.encode(TarEncoder().encode(archive)));
Map<String, String> source(Map<String, dynamic> envelope) => {
  for (final file in envelope['files'] as List)
    file['path'] as String: utf8.decode(base64Decode(file['data'] as String)),
};

void main() {
  test('standard npm tarball preserves source and carries optional appearance metadata', () {
    final original = envelope();
    final bytes = WishPluginPackage.encode(
      original,
      identity: {
        'customName': '我的清单',
        'icon': {'builtin': 'note'},
        'private': 'discarded',
      },
    );
    expect(bytes.take(2), [0x1f, 0x8b]);
    final standard = TarDecoder().decodeBytes(gzip.decode(bytes));
    expect(standard.files.map((file) => file.name), everyElement(startsWith('package/')));
    final manifest = jsonDecode(
      utf8.decode(standard.files.singleWhere((file) => file.name == 'package/package.json').content as List<int>),
    );
    expect(manifest['name'], '@local/local-share-test');
    expect(manifest['exports'], {'.': './index.js'});
    expect(manifest['dshAnyApp'], {
      'version': 1,
      'api': 2,
      'title': '我的清单',
      'icon': {'builtin': 'note'},
    });
    expect(manifest.containsKey('private'), isFalse);
    final restored = WishPluginPackage.decode(bytes);
    expect(restored['sourceId'], original['sourceId']);
    expect(restored['title'], '我的清单');
    expect(WishPackageIdentity.resolve(restored).icon, {'builtin': 'note'});
    expect(source(restored)['index.js'], source(original)['index.js']);
    expect(source(restored)['locale/zh.json'], source(original)['locale/zh.json']);
  });

  test('old JSON packages remain accepted without rewriting their source checksum', () {
    final original = envelope();
    final restored = WishPluginPackage.decode(Uint8List.fromList(utf8.encode(jsonEncode(original))));
    expect(restored['hash'], original['hash']);
    expect(restored['files'], original['files']);
  });

  test('ordinary local DSH tarball without AnyApp metadata derives locale title', () {
    final archive = Archive();
    for (final file in source(envelope()).entries) {
      final data = utf8.encode(file.value);
      archive.addFile(ArchiveFile('package/${file.key}', data.length, data));
    }
    expect(WishPluginPackage.decode(tarball(archive))['title'], '分享清单');
  });

  test('USTAR prefix supports long source paths without PAX extension headers', () {
    final path = 'assets/${List.filled(8, 'directory').join('/')}/style.css';
    final restored = WishPluginPackage.decode(WishPluginPackage.encode(envelope(extra: {path: 'body{color:red}'})));
    expect(source(restored)[path], 'body{color:red}');
  });

  test('compressed expansion and input size are limited before tar decoding', () {
    final bomb = Uint8List.fromList(gzip.encode(Uint8List(3000000)));
    expect(bomb.length, lessThan(10000));
    expect(() => WishPluginPackage.decode(bomb), throwsFormatException);
    expect(() => WishPluginPackage.decode(Uint8List(2000001)), throwsFormatException);
  });

  test('traversal, absolute paths and symlinks cannot enter the package', () {
    for (final path in [
      'package/../bad.js',
      '/package/index.js',
      'package/assets/../../bad.js',
      'other/index.js',
      'package/C:/bad.js',
    ]) {
      final archive = Archive()..addFile(ArchiveFile(path, 1, [65]));
      expect(() => WishPluginPackage.decode(tarball(archive)), throwsFormatException, reason: path);
    }
    final link = ArchiveFile('package/link.js', 0, [])
      ..isSymbolicLink = true
      ..nameOfLinkedFile = '../../outside';
    expect(() => WishPluginPackage.decode(tarball(Archive()..addFile(link))), throwsFormatException);
  });

  test('PAX and hard-link header types are rejected even when their checksum is valid', () {
    final raw = Uint8List.fromList(TarEncoder().encode(Archive()..addFile(ArchiveFile('package/index.js', 1, [65]))));
    for (final type in [49, 120, 103, 76]) {
      final changed = Uint8List.fromList(raw)..[156] = type;
      changed.fillRange(148, 156, 32);
      final checksum = changed.take(512).fold<int>(0, (sum, value) => sum + value);
      changed.setRange(148, 156, ascii.encode('${checksum.toRadixString(8).padLeft(6, '0')}\x00 '));
      expect(() => WishPluginPackage.decode(Uint8List.fromList(gzip.encode(changed))), throwsFormatException);
    }
  });

  test('private records, install scripts and non-local packages are rejected', () {
    for (final manifest in [
      '{"name":"other-package"}',
      '{"name":"@local/local-share-test","scripts":{"postinstall":"anything"}}',
    ]) {
      final data = utf8.encode(manifest);
      expect(
        () => WishPluginPackage.decode(
          tarball(Archive()..addFile(ArchiveFile('package/package.json', data.length, data))),
        ),
        throwsFormatException,
      );
    }
    final original = source(envelope());
    final archive = Archive();
    for (final file in {...original, 'records/private.json': '{}'}.entries) {
      final bytes = utf8.encode(file.value);
      archive.addFile(ArchiveFile('package/${file.key}', bytes.length, bytes));
    }
    expect(() => WishPluginPackage.decode(tarball(archive)), throwsFormatException);
  });
}
