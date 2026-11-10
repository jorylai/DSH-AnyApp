import 'dart:convert';
import 'dart:io';

import 'package:dsh_app/wish/wish_builtin_updates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shipped coach update matches the actual portable client', () {
    final rule = jsonDecode(File('assets/presets/calorie-update.json').readAsStringSync()) as Map<String, dynamic>;
    final bundle = jsonDecode(File('assets/presets/calorie.anyapp').readAsStringSync()) as Map<String, dynamic>;
    expect(WishBuiltinUpdates.clientHash(bundle), rule['targetClientHash']);
    expect(bundle['hash'], rule['bundleHash']);
  });
  test('identity rewriting preserves canonical source while user edits change it', () {
    Map<String, dynamic> envelope(String id, String body) => {
      'sourceId': id,
      'files': [
        {'path': 'client.js', 'data': base64Encode(utf8.encode(body))},
      ],
    };
    final one = envelope('local-one', "const panel='local-one';const rpc='local_one';");
    final two = envelope('local-two', "const panel='local-two';const rpc='local_two';");
    expect(WishBuiltinUpdates.clientHash(one), WishBuiltinUpdates.clientHash(two));
    final edited = envelope('local-two', "const panel='local-two';const rpc='local_two';const custom=true;");
    expect(WishBuiltinUpdates.clientHash(one), isNot(WishBuiltinUpdates.clientHash(edited)));
  });
}
