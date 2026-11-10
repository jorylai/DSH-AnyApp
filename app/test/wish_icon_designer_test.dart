import 'dart:convert';

import 'package:dsh_app/wish/wish_icon_designer.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> design({List<Map<String, dynamic>>? shapes}) => {
  'kind': 'vector',
  'palette': 'mint',
  'variant': 1,
  'shapes':
      shapes ??
      [
        {'type': 'circle', 'cx': 32, 'cy': 32, 'r': 16},
        {'type': 'roundRect', 'x': 24, 'y': 20, 'w': 16, 'h': 24, 'r': 6, 'fill': 'accent'},
        {
          'type': 'path',
          'points': [
            [16, 44],
            [32, 52],
            [48, 44],
          ],
          'stroke': 'white',
          'width': 3,
        },
      ],
};

void main() {
  test('fenced design becomes bounded composable shapes instead of a preset glyph', () {
    final result = WishIconDesigner.parse('```json\n${jsonEncode(design())}\n```');
    expect(result['kind'], 'vector');
    final shapes = result['shapes'] as List;
    expect(shapes[0]['fill'], 'foreground');
    expect(shapes[2]['closed'], false);
    expect(shapes[2]['points'][1], [32.0, 52.0]);
    expect(WishIconDesigner.normalize(result), result);
  });

  test('rejects model-proposed endpoints, SVG and executable properties', () {
    for (final field in ['endpoint', 'url', 'svg', 'code']) {
      expect(
        () => WishIconDesigner.parse(jsonEncode({...design(), field: 'https://example.com/images'})),
        throwsFormatException,
      );
    }
    final shape = {'type': 'circle', 'cx': 32, 'cy': 32, 'r': 10, 'onLoad': 'alert(1)'};
    expect(() => WishIconDesigner.normalize(design(shapes: [shape])), throwsFormatException);
    expect(() => WishIconDesigner.parse('Here is an image: https://example.com/image.png'), throwsFormatException);
    expect(() => WishIconDesigner.parse('```json\n${jsonEncode(design())}\n```\nextra'), throwsFormatException);
  });

  test('rejects overflow, non-finite numbers and unsupported shapes', () {
    final invalid = [
      {'type': 'circle', 'cx': 2, 'cy': 32, 'r': 10},
      {'type': 'circle', 'cx': double.nan, 'cy': 32, 'r': 10},
      {'type': 'circle', 'cx': 32, 'cy': 32, 'r': double.infinity},
      {'type': 'roundRect', 'x': 50, 'y': 2, 'w': 20, 'h': 12, 'r': 3},
      {'type': 'roundRect', 'x': 12, 'y': 12, 'w': 10, 'h': 10, 'r': 9},
      {
        'type': 'path',
        'points': [
          [4, 4],
          [65, 8],
        ],
        'stroke': 'foreground',
      },
      {
        'type': 'path',
        'points': [
          [4, 4],
          [8, 8],
        ],
        'fill': 'accent',
        'closed': true,
      },
      {
        'type': 'path',
        'points': [
          [4, 4],
          [8, 8],
        ],
        'stroke': 'foreground',
        'width': 100,
      },
      {'type': 'svg', 'fill': 'foreground'},
      {'type': 'circle', 'cx': 32, 'cy': 32, 'r': 10, 'fill': 'none'},
    ];
    for (final shape in invalid) {
      expect(() => WishIconDesigner.normalize(design(shapes: [shape])), throwsFormatException, reason: '$shape');
    }
  });

  test('enforces total shape and path budgets before rendering', () {
    expect(
      () => WishIconDesigner.normalize(
        design(shapes: List.generate(17, (_) => {'type': 'circle', 'cx': 32, 'cy': 32, 'r': 10})),
      ),
      throwsFormatException,
    );
    final path = {
      'type': 'path',
      'points': List.generate(49, (_) => [4, 4]),
      'stroke': 'foreground',
    };
    expect(() => WishIconDesigner.normalize(design(shapes: [path, path])), throwsFormatException);
    expect(() => WishIconDesigner.normalize({...design(), 'variant': 0.5}), throwsFormatException);
    expect(() => WishIconDesigner.normalize({...design(), 'palette': '#ff00ff'}), throwsFormatException);
    expect(() => WishIconDesigner.normalize(design(shapes: [])), throwsFormatException);
  });

  test('prompt keeps context bounded and never embeds a persisted bitmap', () {
    final prompt = WishIconDesigner.prompt(
      name: '热量助手',
      purpose: 'Food logging ${'x' * 1000}',
      request: '橙色碗与一片叶子',
      previous: {'bitmap': 'SECRET_BITMAP', 'builtin': 'heart'},
    );
    expect(prompt, contains('热量助手'));
    expect(prompt, contains('橙色碗与一片叶子'));
    expect(prompt, isNot(contains('SECRET_BITMAP')));
    expect(prompt, isNot(contains('x' * 601)));
    expect(prompt, contains('not a selection from an existing icon list'));
  });

  test('valid prior design reaches the model while invalid prior data is ignored', () {
    expect(
      WishIconDesigner.prompt(
        name: 'trip',
        purpose: '',
        previous: {...design(), 'bitmap': 'SECRET_BITMAP', 'styleVersion': 2},
      ),
      contains('previousDesign'),
    );
    expect(
      WishIconDesigner.prompt(name: 'trip', purpose: '', previous: {...design(), 'shapes': []}),
      isNot(contains('previousDesign')),
    );
  });
}
