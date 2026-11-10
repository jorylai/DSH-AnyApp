import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/wish/wish_identity.dart';

void main() {
  test('user naming survives a later creator product title change', () {
    const identity = WishIdentity({'customName': '我的助手', 'title': '小助 2'});
    expect(identity.name('原始长需求'), '我的助手');
    expect(const WishIdentity({'customName': ' ', 'title': '番茄刻度'}).name('原始需求'), '番茄刻度');
    expect(const WishIdentity({}).name('旧名字'), '旧名字');
  });
}
