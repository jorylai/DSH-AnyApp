import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Read-only fingerprints for inspecting portable work packages.
/// A bundled package is never applied automatically when a user opens a work.
class WishBuiltinUpdates {
  static String canonicalClient(String text, String id) =>
      text.replaceAll(id, '__WORK_ID__').replaceAll(id.replaceAll('-', '_'), '__WORK_RPC__');
  static String clientHash(Map<String, dynamic> envelope) {
    final source = envelope['sourceId'];
    if (source is! String || envelope['files'] is! List) return '';
    final file = (envelope['files'] as List).whereType<Map>().where((f) => f['path'] == 'client.js').firstOrNull;
    if (file == null || file['data'] is! String) return '';
    final text = utf8.decode(base64Decode(file['data'] as String));
    return sha256.convert(utf8.encode(canonicalClient(text, source))).toString();
  }
}
