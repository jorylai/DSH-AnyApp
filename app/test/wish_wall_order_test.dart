import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dsh_app/wish/wish_wall_order.dart';
import 'package:dsh_app/state/account_api.dart';

void main() {
  const works = [(id: 'old', added: 1), (id: 'new', added: 2), (id: 'legacy', added: 0)];
  test('newest uses addition time rather than last edit and preserves indices', () {
    expect(wishWallOrder(works, WishWallSort.added, {'old': 100}), [1, 0, 2]);
    expect(wishWallOrder(works, WishWallSort.recent, {'old': 80, 'legacy': 90}), [2, 0, 1]);
    expect(wishWallOrder(works, WishWallSort.recent, {}), [1, 0, 2]);
  });
  test('opening records only the selected work and survives preferences reload', () async {
    SharedPreferences.setMockInitialValues({'wish-wall-used:other': 4});
    await recordWishOpen('selected');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('wish-wall-used:selected'), greaterThan(4));
    expect(prefs.getInt('wish-wall-used:other'), 4);
  });
  test('authorization destination shows fixed host/path without one-time query', () {
    expect(
      accountAuthorizationDestination('https://platform.deepseek.com/dsh/authorize?authorize_id=example&state=example'),
      'https://platform.deepseek.com/dsh/authorize',
    );
    expect(accountAuthorizationDestination('https://user:example@platform.deepseek.com/dsh/authorize'), isNull);
    expect(accountAuthorizationDestination('javascript:alert(1)'), isNull);
  });
}
