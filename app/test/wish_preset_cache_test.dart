import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dsh_app/wish/wish_preset_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wish-preset-cache-test-');
  });
  tearDown(() async {
    await dir.delete(recursive: true);
  });
  test('an updated APK cannot replace an intact pending source cache', () async {
    final old = _package('old'), updated = _package('new');
    var asset = old, loads = 0;
    final cache = WishPresetPackageCache(
      dir,
      loadAsset: (_) async {
        loads++;
        return asset;
      },
    );
    final first = await cache.prepare('local-target', 'voyo');
    asset = updated;
    final restored = await cache.prepare('local-target', 'voyo', expectedHash: first['hash'] as String);
    expect(restored['hash'], first['hash']);
    expect(loads, 1);
  });
  test('corrupted cached code is repaired only from the original pinned version', () async {
    final original = _package('old');
    final cache = WishPresetPackageCache(dir, loadAsset: (_) async => original);
    final first = await cache.prepare('local-target', 'voyo');
    final file = File('${dir.path}/local-target.anyapp');
    await file.writeAsString('{interrupted');
    final recovered = await cache.prepare('local-target', 'voyo', expectedHash: first['hash'] as String);
    expect(recovered['hash'], first['hash']);
    expect(WishPresetPackageCache.validate(await file.readAsString())['hash'], first['hash']);
  });
  test('corruption plus a changed APK asset fails explicitly without overwriting the pinned target', () async {
    final oldHash = (jsonDecode(_package('old')) as Map)['hash'] as String;
    final file = File('${dir.path}/local-target.anyapp');
    await file.writeAsString('corrupt');
    final cache = WishPresetPackageCache(dir, loadAsset: (_) async => _package('new'));
    await expectLater(cache.prepare('local-target', 'voyo', expectedHash: oldHash), throwsFormatException);
    expect(await file.readAsString(), 'corrupt');
  });
  test('a missing pinned cache cannot silently switch to a newer bundled version', () async {
    final oldHash = (jsonDecode(_package('old')) as Map)['hash'] as String;
    final cache = WishPresetPackageCache(dir, loadAsset: (_) async => _package('new'));
    await expectLater(cache.prepare('local-target', 'calorie', expectedHash: oldHash), throwsFormatException);
    expect(await File('${dir.path}/local-target.anyapp').exists(), isFalse);
  });
  test('a half-written temporary file is atomically replaced from a verified asset', () async {
    final temp = File('${dir.path}/local-target.anyapp.tmp');
    await temp.writeAsString('interrupted write');
    final cache = WishPresetPackageCache(dir, loadAsset: (_) async => _package('old'));
    final source = await cache.prepare('local-target', 'voyo');
    expect(source['title'], 'Starter');
    expect(await temp.exists(), isFalse);
    expect(
      WishPresetPackageCache.validate(await File('${dir.path}/local-target.anyapp').readAsString())['hash'],
      source['hash'],
    );
  });
  test('a tampered file is rejected before source is cached', () async {
    final value = jsonDecode(_package('old')) as Map;
    (value['files'] as List).first['data'] = base64Encode(utf8.encode('changed'));
    final cache = WishPresetPackageCache(dir, loadAsset: (_) async => jsonEncode(value));
    await expectLater(cache.prepare('local-target', 'voyo'), throwsFormatException);
    expect(await dir.list().toList(), isEmpty);
  });
  test('real multi-file plugin sources pass, while a data directory is rejected', () {
    final value = jsonDecode(_package('old')) as Map<String, dynamic>;
    expect((WishPresetPackageCache.validate(jsonEncode(value))['files'] as List).length, 5);
    final files = (value['files'] as List).cast<Map<String, dynamic>>()
      ..add(_file('data/records.js', 'export const records = [];'));
    files.sort((a, b) => (a['path'] as String).compareTo(b['path'] as String));
    value['files'] = files;
    value['hash'] = sha256.convert(utf8.encode(jsonEncode(files))).toString();
    expect(() => WishPresetPackageCache.validate(jsonEncode(value)), throwsFormatException);
  });
  test('cache does not follow a symlink to another app file', () async {
    final outside = File('${dir.path}/do-not-change')..writeAsStringSync('user data');
    await Link('${dir.path}/local-target.anyapp').create(outside.path);
    final cache = WishPresetPackageCache(dir, loadAsset: (_) async => _package('old'));
    await expectLater(cache.prepare('local-target', 'voyo'), throwsFormatException);
    expect(await outside.readAsString(), 'user data');
  });
}

String _package(String version) {
  final files = [
    _file('client.jsx', 'export default function App() { return <main>Ready</main>; }\n'),
    _file('cordis.patch.yml', 'plugins:\n  - ./index.js\n'),
    _file('index.js', 'export const version = "$version";\n'),
    _file('package.json', '{"name":"@local/local-source","version":"1.0.0"}\n'),
    _file('style.css', 'main { color: white; }\n'),
  ];
  return jsonEncode({
    'format': 'dsh-anyapp-plugin/1',
    'api': 2,
    'portable': true,
    'sourceId': 'local-source',
    'title': 'Starter',
    'hash': sha256.convert(utf8.encode(jsonEncode(files))).toString(),
    'files': files,
  });
}

Map<String, String> _file(String path, String content) => {
  'path': path,
  'data': base64Encode(utf8.encode(content)),
  'sha256': sha256.convert(utf8.encode(content)).toString(),
};
