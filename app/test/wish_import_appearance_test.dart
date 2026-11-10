import 'dart:convert';

import 'package:dsh_app/wish/wish_preset_installer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explicit shared name and icon become user metadata overrides', () {
    expect(
      WishPresetInstaller.sharedAppearanceOverrides({
        'title': 'Old creation prompt',
        'presentation': {
          'version': 1,
          'title': ' 比价雷达 ',
          'icon': {'builtin': 'cart', 'private': 'not portable'},
          'actions': ['not imported as identity'],
        },
      }),
      {
        'customName': '比价雷达',
        'icon': {'builtin': 'cart'},
      },
    );
  });

  test('legacy recovered metadata stays declared so future plugin updates work', () {
    expect(
      WishPresetInstaller.sharedAppearanceOverrides({
        'title': 'A legacy title',
        'files': [
          {'path': 'locale/zh.json', 'data': base64Encode(utf8.encode('{"meta":{"title":"比价雷达"}}'))},
          {'path': 'icon.svg', 'data': base64Encode(utf8.encode('<svg><rect width="64" height="64"/></svg>'))},
        ],
      }),
      isEmpty,
    );
  });

  test('title-only and icon-only sharing override only the explicitly chosen field', () {
    expect(
      WishPresetInstaller.sharedAppearanceOverrides({
        'presentation': {'version': 1, 'title': 'My radar'},
      }),
      {'customName': 'My radar'},
    );
    expect(
      WishPresetInstaller.sharedAppearanceOverrides({
        'title': 'Name must remain plugin managed',
        'presentation': {
          'version': 1,
          'icon': {'builtin': 'timer'},
        },
      }),
      {
        'icon': {'builtin': 'timer'},
      },
    );
  });

  test('invalid or unknown presentation cannot pin a fallback name or icon', () {
    for (final presentation in [
      {
        'version': 99,
        'title': 'Unknown',
        'icon': {'builtin': 'cart'},
      },
      {
        'version': 1,
        'title': ' \n\u0000 ',
        'icon': {'bitmap': 'broken'},
      },
      {
        'version': 1,
        'title': List.filled(81, 'x').join(),
        'icon': {'url': 'https://example.test/icon'},
      },
    ]) {
      expect(
        WishPresetInstaller.sharedAppearanceOverrides({
          'title': 'Fallback should stay editable',
          'presentation': presentation,
        }),
        isEmpty,
      );
    }
  });
}
