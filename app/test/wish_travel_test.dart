import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/wish/wish_travel.dart';

void main() {
  String result(Map<String, dynamic> row) => jsonEncode({
    'items': [row],
  });
  test('review preserves missing times rather than manufacturing a booking', () {
    final row = WishTravel.parse(
      result({
        'title': '待确认酒店',
        'start': null,
        'end': null,
        'missing': ['入住日期'],
      }),
      zone: 'Asia/Shanghai',
    ).single;
    expect(row['start'], isNull);
    expect(row['missing'], ['入住日期']);
    expect(row['timeZone'], 'Asia/Shanghai');
  });
  test('cross-timezone trip compares instants and preserves offsets', () {
    final row = WishTravel.parse(
      '```json\n${result({'title': '航班', 'start': '2026-11-10T10:00:00+08:00', 'end': '2026-11-10T04:00:00Z', 'timeZone': 'Asia/Shanghai'})}\n```',
      zone: 'UTC',
    ).single;
    expect(row['start'], '2026-11-10T10:00:00+08:00');
  });
  test('rejects offset-free times, reversed ranges and unknown zones', () {
    for (final row in [
      {'title': '错误', 'start': '2026-11-10T10:00:00'},
      {'title': '错误', 'start': '2026-11-10T10:00:00Z', 'end': '2026-11-10T09:00:00Z'},
      {'title': '错误', 'timeZone': 'invented/zone'},
    ]) {
      expect(() => WishTravel.parse(result(row), zone: 'UTC'), throwsStateError);
    }
  });
}
