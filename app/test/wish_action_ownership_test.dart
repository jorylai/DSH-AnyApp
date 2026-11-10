import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsh_app/wish/wish_actions.dart';
import 'package:dsh_app/wish/wish_device.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('headless readiness never registers as the floating UI owner', () async {
    final methods=<String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (c) async { methods.add(c.method);return null; });
    final container=ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(()=>TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel,null));
    await WishActions.init(container,foreground:false);
    expect(methods,['background.listen']);
    methods.clear();
    await WishActions.init(container);
    expect(methods,['actions.listen']);
  });
}
