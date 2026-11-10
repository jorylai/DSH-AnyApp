import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dsh_app/pets/pet_pack.dart';
import 'package:dsh_app/pets/pet_state.dart';
import 'package:dsh_app/ui/shell/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('saved pet identities still decode with original AnyApp artwork', () async {
    for (final id in ['deepy-whale', 'whale-girl']) {
      final dir = Directory('assets/pets/$id');
      final json = jsonDecode(File('${dir.path}/pack.json').readAsStringSync()) as Map<String, Object?>;
      final pack = PetPack.parse(json);
      expect(pack.id, id);
      expect(pack.author, 'DSH AnyApp');
      expect(pack.name, startsWith('AnyApp'));
      for (final state in PetStateName.values) {
        expect(pack.animFor(state).frames, isNotEmpty);
      }
      for (final anim in pack.animations.values) {
        final codec = await ui.instantiateImageCodec(File('${dir.path}/${anim.sheet}').readAsBytesSync());
        final image = (await codec.getNextFrame()).image;
        for (final frame in anim.frames) {
          final rect = anim.sourceRect(frame.i);
          expect(rect.right <= image.width && rect.bottom <= image.height, isTrue);
        }
        image.dispose();
        codec.dispose();
      }
    }
  });
  testWidgets('AnyApp brand supports monochrome and themed renderers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            BrandMark(tile: true),
            BrandMark(color: Colors.white),
            BrandMark(),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
