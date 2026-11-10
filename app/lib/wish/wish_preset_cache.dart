import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Pins bundled source before installation starts. Updating the APK while a
/// preparation is pending must not switch the package halfway through.
class WishPresetPackageCache {
  WishPresetPackageCache(this.directory, {required this.loadAsset});
  final Directory directory;
  final Future<String> Function(String name) loadAsset;

  Future<Map<String, dynamic>> prepare(String id, String name, {String? expectedHash}) async {
    if (!RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(id) ||
        !['voyo', 'calorie', 'radar', 'pomodoro'].contains(name)) {
      throw const FormatException('invalid-preset-cache');
    }
    await directory.create(recursive: true);
    final target = File('${directory.path}/$id.anyapp');
    final kind = await FileSystemEntity.type(target.path, followLinks: false);
    if (kind != FileSystemEntityType.notFound && kind != FileSystemEntityType.file) {
      throw const FormatException('invalid-preset-cache');
    }
    if (kind == FileSystemEntityType.file) {
      try {
        if (await target.length() > 2000000) throw const FormatException('release-exceeds-limit');
        final cached = validate(await target.readAsString());
        if (expectedHash != null && cached['hash'] != expectedHash) {
          throw const FormatException('preset-cache-hash-changed');
        }
        return cached;
      } on FormatException {
        // Repair only from the exact pinned source. A changed APK asset cannot
        // be substituted for a damaged pending installation.
      }
    }
    final text = await loadAsset(name);
    final envelope = validate(text);
    if (expectedHash != null && envelope['hash'] != expectedHash) {
      throw const FormatException('preset-cache-pinned-version-unavailable');
    }
    final temp = File('${target.path}.tmp');
    final tempKind = await FileSystemEntity.type(temp.path, followLinks: false);
    if (tempKind != FileSystemEntityType.notFound && tempKind != FileSystemEntityType.file) {
      throw const FormatException('invalid-preset-cache');
    }
    await temp.writeAsString(text, flush: true);
    await temp.rename(target.path);
    return envelope;
  }

  static Map<String, dynamic> validate(String text) {
    if (utf8.encode(text).length > 2000000) throw const FormatException('release-exceeds-limit');
    final decoded = jsonDecode(text);
    if (decoded is! Map) throw const FormatException('release-incompatible-format');
    final value = decoded.cast<String, dynamic>();
    final files = value['files'];
    if (value['format'] != 'dsh-anyapp-plugin/1' ||
        value['portable'] != true ||
        value['api'] is! int ||
        value['api'] < 1 ||
        value['api'] > 2 ||
        value['sourceId'] is! String ||
        !RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(value['sourceId']) ||
        value['title'] is! String ||
        (value['title'] as String).trim().isEmpty ||
        value['title'].length > 80 ||
        files is! List ||
        files.isEmpty ||
        files.length > 512 ||
        value['hash'] is! String) {
      throw const FormatException('release-incompatible-format');
    }
    final sorted = <Map<String, dynamic>>[], paths = <String>{};
    var bytes = 0;
    for (final raw in files) {
      if (raw is! Map) throw const FormatException('release-invalid-file');
      final file = raw.cast<String, dynamic>();
      final path = file['path'], data = file['data'];
      if (path is! String ||
          path.isEmpty ||
          path.startsWith('/') ||
          path.contains('\\') ||
          path.split('/').any((part) => part.isEmpty || part == '.' || part == '..') ||
          !paths.add(path) ||
          data is! String ||
          !RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(data)) {
        throw const FormatException('release-invalid-file');
      }
      final content = base64Decode(data);
      bytes += content.length;
      if (bytes > 1500000 || sha256.convert(content).toString() != file['sha256']) {
        throw const FormatException('release-integrity-failed');
      }
      final privatePath = RegExp(
        r'(^|/)(node_modules|\.git|\.dsh|\.env[^/]*|credentials?[^/]*|sessions?|records?|data)(/|$)|\.(log|db|sqlite|jks|keystore)$',
        caseSensitive: false,
      );
      final sourceFile =
          RegExp(r'(^|/)(LICENSE|NOTICE|COPYING)(\.[A-Za-z0-9_-]+)?$', caseSensitive: false).hasMatch(path) ||
          path == 'package.json' ||
          RegExp(r'^README(?:[._-][A-Za-z0-9_-]+)?\.md$', caseSensitive: false).hasMatch(path) ||
          (RegExp(r'^(locale|i18n)/').hasMatch(path) && path.endsWith('.json')) ||
          RegExp(r'\.(m?js|cjs|jsx|tsx?|css|html|svg|png|webp|jpe?g|woff2?|ya?ml)$').hasMatch(path) ||
          (RegExp(r'^(assets|schema)/').hasMatch(path) && path.endsWith('.json'));
      if (path.length >= 240 ||
          privatePath.hasMatch(path) ||
          !sourceFile ||
          path.contains(value['sourceId'] as String) ||
          path.contains((value['sourceId'] as String).replaceAll('-', '_'))) {
        throw const FormatException('release-invalid-file');
      }
      sorted.add(file);
    }
    sorted.sort((a, b) => (a['path'] as String).compareTo(b['path'] as String));
    if (!paths.contains('package.json') ||
        sha256.convert(utf8.encode(jsonEncode(sorted))).toString() != value['hash']) {
      throw const FormatException('release-integrity-failed');
    }
    final packageFile = sorted.firstWhere((file) => file['path'] == 'package.json');
    final packageValue = jsonDecode(utf8.decode(base64Decode(packageFile['data'] as String)));
    if (packageValue is! Map ||
        packageValue['name'] != '@local/${value['sourceId']}' ||
        (packageValue['scripts'] != null &&
            (packageValue['scripts'] is! Map || (packageValue['scripts'] as Map).isNotEmpty)) ||
        (packageValue['dependencies'] != null &&
            (packageValue['dependencies'] is! Map ||
                (packageValue['dependencies'] as Map).values.any(
                  (dep) => dep is! String || RegExp(r'^(file:|link:|workspace:|/|\.\.)').hasMatch(dep),
                )))) {
      throw const FormatException('release-not-portable');
    }
    return value;
  }
}
