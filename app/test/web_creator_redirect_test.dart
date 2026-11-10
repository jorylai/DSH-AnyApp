import 'package:dsh_app/ui/web/web_target.dart';
import 'package:dsh_app/ui/web/web_view_page.dart';
import 'package:dsh_app/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  late _Platform platform;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    platform = _Platform();
    WebViewPlatform.instance = platform;
  });

  Future<void> flush(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
  }

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(glassBlur: false, instantPages: true),
        home: WebViewPage(
          url: Uri.parse('http://127.0.0.1:3080/?token=test-only'),
          title: 'Creator',
          dshWeb: true,
          phoneLayout: false,
          openTarget: const DshWebTarget(sessionId: 'session-new-request'),
        ),
      ),
    );
    await flush(tester);
  }

  testWidgets('launch redirect replays the new Creator destination in the replacement document', (tester) async {
    await mount(tester);
    final web = platform.controller;
    final delegate = platform.delegate;
    delegate.started!(web.url!);
    delegate.finished!(web.url!);
    await flush(tester);
    expect(web.destinations, hasLength(1));
    web.url = 'http://127.0.0.1:3080/';
    delegate.started!(web.url!); // Android replaced the launch-token document.
    delegate.finished!(web.url!);
    await flush(tester);
    expect(web.destinations, hasLength(2), reason: 'the request must not be spent on the outgoing login document');
    expect(web.destinations.last, contains('session-new-request'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an outgoing page finish cannot consume the new page destination', (tester) async {
    await mount(tester);
    final web = platform.controller;
    final delegate = platform.delegate;
    web.url = 'http://127.0.0.1:3080/';
    delegate.started!(web.url!);
    delegate.finished!('http://127.0.0.1:3080/?token=test-only');
    await flush(tester);
    expect(web.destinations, isEmpty);
    delegate.finished!(web.url!);
    await flush(tester);
    expect(web.destinations, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Platform extends WebViewPlatform {
  late _Controller controller;
  late _Delegate delegate;
  @override
  PlatformWebViewController createPlatformWebViewController(PlatformWebViewControllerCreationParams params) =>
      controller = _Controller(params);
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(PlatformNavigationDelegateCreationParams params) =>
      delegate = _Delegate(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(PlatformWebViewWidgetCreationParams params) => _View(params);
}

class _View extends PlatformWebViewWidget {
  _View(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params) : super.implementation();
  String? url;
  final scripts = <String>[];
  List<String> get destinations => scripts.where((s) => s.startsWith('window.__dshAppOpen &&')).toList();
  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    url = params.uri.toString();
  }

  @override
  Future<String?> currentUrl() async => url;
  @override
  Future<void> runJavaScript(String script) async {
    scripts.add(script);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String script) async => false;
  @override
  Future<void> setPlatformNavigationDelegate(PlatformNavigationDelegate handler) async {}
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();
  PageEventCallback? started, finished;
  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    started = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finished = callback;
  }

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback callback) async {}
  @override
  Future<void> setOnProgress(ProgressCallback callback) async {}
  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {}
}
