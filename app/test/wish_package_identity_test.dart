import 'dart:convert';
import 'dart:io';

import 'package:dsh_app/wish/wish_package_identity.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> bundle({
  String title = 'Make a shopping tool with a floating button',
  Map<String, String> files = const {},
  Map<String, dynamic>? presentation,
}) => {
  'title': title,
  'hash': 'source-checksum-kept',
  'presentation': ?presentation,
  'files': [
    for (final entry in files.entries) {'path': entry.key, 'data': base64Encode(utf8.encode(entry.value))},
  ],
};

const icon =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#123456"/><stop offset="1" stop-color="#789abc"/></linearGradient></defs><rect width="64" height="64" rx="16" fill="url(#bg)"/><path d="M16 32L30 46L48 18" fill="none" stroke="#ffffff" stroke-width="3"/></svg>';

void main() {
  test('bundled starter names do not turn into their package descriptions', () {
    for (final entry in {'radar': '比价雷达', 'pomodoro': '番茄钟'}.entries) {
      final source = jsonDecode(File('assets/presets/${entry.key}.anyapp').readAsStringSync()) as Map<String, dynamic>;
      expect(WishPackageIdentity.resolve(source).title, entry.value, reason: entry.key);
      if (entry.key == 'radar') {
        expect(source['declaredVersion'], '1.25.0');
        expect(WishPackageIdentity.resolve(source).icon['svg'], contains('prSweep'));
      }
    }
  });

  test('short declared app names beat descriptions while locale still recovers a legacy radar prompt', () {
    expect(
      WishPackageIdentity.resolve(
        bundle(title: '番茄钟', files: {'package.json': '{"description":"按真实时间专注与休息，离开页面继续计时。"}'}),
      ).title,
      '番茄钟',
    );
    expect(
      WishPackageIdentity.resolve(
        bundle(
          title: '做一个电商外卖比价工具，打开后唤起悬浮按钮，当我浏览某个具体商品时可以点击它帮我查询其他平台价格',
          files: {'locale/zh.json': '{"meta":{"title":"比价雷达"}}', 'package.json': '{"description":"商品、酒店、机票都比价"}'},
        ),
      ).title,
      '比价雷达',
    );
  });

  test('legacy locale title and declared icon beat a creation prompt', () {
    final identity = WishPackageIdentity.resolve(
      bundle(
        files: {
          'locale/zh.json': '{"meta":{"title":"购物清单"}}',
          'locale/en.json': '{"meta":{"title":"Shopping list"}}',
          'package.json': '{"displayName":"Another title","description":"Description title: extra detail","exports":{"./icon":"./assets/mark.svg"}}',
          'assets/mark.svg': icon,
        },
      ),
    );
    expect(identity.title, '购物清单');
    expect(identity.icon['svg'], contains('linearGradient'));
    expect(identity.icon['svg'], contains('url(#bg)'));
  });

  test('export attaches only portable appearance and preserves the source checksum', () {
    final original = bundle(title: 'Old prompt');
    final result = WishPackageIdentity.attach(
      original,
      identity: {
        'customName': '我的清单',
        'title': 'Declared title',
        'id': 'private-work-id',
        'actions': [
          {'private': 'not exported'},
        ],
        'icon': {'builtin': 'cart', 'secret': 'not exported'},
      },
    );
    expect(result['title'], '我的清单');
    expect(result['hash'], original['hash']);
    expect(result['files'], same(original['files']));
    expect(result['presentation'], {
      'version': 1,
      'title': '我的清单',
      'icon': {'builtin': 'cart'},
    });
    expect(original.containsKey('presentation'), isFalse);
    expect(WishPackageIdentity.resolve(result).title, '我的清单');
    expect(WishPackageIdentity.resolve(result).icon, {'builtin': 'cart'});
  });

  test('shared presentation wins over legacy metadata but rejects unknown presentation versions', () {
    final files = {'locale/zh.json': '{"meta":{"title":"Original"}}'};
    final resolved = WishPackageIdentity.resolve(
      bundle(
        files: files,
        presentation: {
          'version': 1,
          'title': 'Shared name',
          'icon': {'builtin': 'timer'},
        },
      ),
    );
    expect(resolved.title, 'Shared name');
    expect(resolved.icon, {'builtin': 'timer'});
    expect(
      WishPackageIdentity.resolve(bundle(files: files, presentation: {'version': 99, 'title': 'Unknown'})).title,
      'Original',
    );
  });

  test('English metadata and short package descriptions support old bundles without locale zh', () {
    expect(
      WishPackageIdentity.resolve(
        bundle(
          files: {
            'locale/en.json': '{"meta":{"title":"Simple timer"}}',
            'package.json': '{"description":"A less useful title: a long explanation"}',
          },
        ),
      ).title,
      'Simple timer',
    );
    expect(
      WishPackageIdentity.resolve(bundle(files: {'package.json': '{"description":"购物清单：记录想买的东西"}'})).title,
      '购物清单',
    );
  });

  test('JavaScript source is never used as appearance metadata and long prompt fallback stays bounded', () {
    final resolved = WishPackageIdentity.resolve(
      bundle(
        title: List.filled(70, '想法').join(),
        files: {
          'client.js': 'globalThis.compromised=true; const meta={title:"Never evaluated"};',
          'locale/zh.json': '{malformed',
        },
      ),
    );
    expect(resolved.title.length, lessThanOrEqualTo(32));
    expect(resolved.title, isNot('Never evaluated'));
    expect(resolved.icon, isEmpty);
  });

  test('SVG accepts static geometry and rejects executable or external content', () {
    expect(WishPackageIdentity.sanitizeSvg(icon), isNotNull);
    for (final svg in [
      '<svg><script>alert(1)</script></svg>',
      '<svg onload="alert(1)"><rect/></svg>',
      '<svg><image href="https://example.test/image.png"/></svg>',
      '<svg><path fill="url(https://example.test/a.svg)"/></svg>',
      '<svg><path style="fill:red"/></svg>',
      '<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///private/file">]><svg/>',
      '<svg><foreignObject><html/></foreignObject></svg>',
      '<svg><use href="#shape"/></svg>',
      '<svg><animate attributeName="x"/></svg>',
    ]) {
      expect(WishPackageIdentity.sanitizeSvg(svg), isNull, reason: svg);
    }
    expect(WishPackageIdentity.sanitizeSvg('<svg><path d="${List.filled(33000, '0').join()}"/></svg>'), isNull);
  });

  test('invalid optional icons fall back without invalidating the work', () {
    final resolved = WishPackageIdentity.resolve(
      bundle(
        files: {'icon.svg': '<svg><script/></svg>'},
        presentation: {
          'version': 1,
          'title': 'Readable name',
          'icon': {'bitmap': 'bad data', 'url': 'https://example.test'},
        },
      ),
    );
    expect(resolved.title, 'Readable name');
    expect(resolved.icon, isEmpty);
    expect(WishPackageIdentity.sanitizeIcon({'builtin': 'unrecognized'}), isNull);
    expect(WishPackageIdentity.sanitizeIcon({'bitmap': base64Encode(List.filled(500000, 0))}), isNull);
  });

  test('bounded native vectors round trip and discard unrelated fields', () {
    final value = WishPackageIdentity.sanitizeIcon({
      'background': '#123456',
      'color': '#abcdef',
      'private': 'ignored',
      'paths': [
        {
          'points': [
            [1, 2],
            [63, 64],
          ],
          'width': 2,
          'closed': true,
          'filled': false,
          'url': 'ignored',
        },
      ],
    });
    expect(value?.keys.toSet(), {'background', 'color', 'paths'});
    expect((value!['paths'] as List).single, {
      'points': [
        [1.0, 2.0],
        [63.0, 64.0],
      ],
      'width': 2,
      'closed': true,
      'filled': false,
    });
    expect(
      WishPackageIdentity.sanitizeIcon({
        'background': '#123456',
        'color': '#abcdef',
        'paths': [
          {
            'points': [
              [-1, 0],
              [64, 64],
            ],
          },
        ],
      }),
      isNull,
    );
  });
}
