import 'dart:async';
import 'dart:convert';

import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/wish/wish_create.dart';
import 'package:dsh_app/wish/wish_creation_plan.dart';
import 'package:dsh_app/wish/wish_creation_service.dart';
import 'package:dsh_app/wish/wish_device.dart';
import 'package:dsh_app/wish/wish_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final submissions = <WishCreationSubmission>[];
  final deviceCalls = <MethodCall>[];
  String response(String brief, {List<String> capabilities = const [], List<String> assumptions = const []}) =>
      jsonEncode({'brief': brief, 'capabilities': capabilities, 'assumptions': assumptions});

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLocale.use(AppLocale.zhCN);
    submissions.clear();
    deviceCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(WishDevice.channel, (
      call,
    ) async {
      deviceCalls.add(call);
      return null;
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      WishDevice.channel,
      null,
    );
  });

  Future<void> show(
    WidgetTester tester, {
    String request = '',
    String? sourceId,
    required Future<String> Function(String) complete,
  }) async {
    await tester.runAsync(() => rootBundle.loadString(WishCreationPlanner.promptAsset));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wishCreationCompleteProvider.overrideWithValue(complete),
          wishCreationStarterProvider.overrideWithValue((ref, submission) async {
            submissions.add(submission);
            // Stop before profile/RPC/navigation work, after capturing the public
            // creation boundary used by the actual Creator implementation.
            throw StateError('captured-for-widget-test');
          }),
        ],
        child: MaterialApp(
          home: WishCreatePage(initialRequest: request, sourceId: sourceId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(finder), alignment: .2);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pumpAndSettle();
  }

  FilterChip chip(WidgetTester tester, String id) => tester.widget<FilterChip>(find.byKey(ValueKey('capability-$id')));

  void expectPreviewTag(WidgetTester tester, String id, String label) {
    final finder = find.byKey(ValueKey('capability-$id'));
    expect(tester.widget(finder), isA<Chip>());
    final text = find.descendant(
      of: finder,
      matching: find.byWidgetPredicate((widget) => widget is RichText && widget.text.toPlainText() == label),
    );
    expect(text, findsOneWidget);
    // Read the rendered style, so inherited disabled styles cannot silently
    // dim the actual preview text while a source TextStyle looks correct.
    expect(tester.widget<RichText>(text).text.style?.color, wishText);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('manual abilities reach the model and confirmed creation without model-added abilities', (tester) async {
    String? optimizerPrompt;
    await show(
      tester,
      complete: (prompt) async {
        optimizerPrompt = prompt;
        return response('只做本地记事，点击时使用 AI 整理。', capabilities: ['phone', 'overlay']);
      },
    );
    await tap(tester, find.byKey(const ValueKey('creation-smart')));
    await tester.enterText(find.byKey(const ValueKey('creation-request')), '做一个简洁的记事本');
    await tap(tester, find.byKey(const ValueKey('capability-ai')));
    expect(chip(tester, 'ai').selected, isTrue);
    expect(chip(tester, 'camera').selected, isFalse);
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(optimizerPrompt, contains('"selectionMode":"manual"'));
    expect(optimizerPrompt, contains('"requiredCapabilities":["ai","storage"]'));
    expect(submissions, isEmpty);
    expectPreviewTag(tester, 'ai', appL10n.wishAi);
    expect(find.byKey(const ValueKey('capability-phone')), findsNothing);
    await tap(tester, find.text(appL10n.wishPlanStart));
    expect(submissions, hasLength(1));
    expect(submissions.single.smart, isFalse);
    expect(submissions.single.capabilities, {WishCreationCapability.ai, WishCreationCapability.storage});
    expect(submissions.single.request, '做一个简洁的记事本');
    expect(deviceCalls, isEmpty, reason: 'Selecting product abilities does not grant system access.');
    await dispose(tester);
  });

  testWidgets('smart suggestions respect an explicit removal and wait for preview confirmation', (tester) async {
    String? optimizerPrompt;
    await show(
      tester,
      request: '做一个拍照识别并保存记录的助手',
      complete: (prompt) async {
        optimizerPrompt = prompt;
        return response('通过用户提供的图片识别内容并保存。', capabilities: ['ai', 'camera', 'storage']);
      },
    );
    expect(chip(tester, 'ai').selected, isTrue);
    expect(chip(tester, 'camera').selected, isTrue);
    await tap(tester, find.byKey(const ValueKey('capability-camera')));
    expect(chip(tester, 'camera').selected, isFalse);
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(optimizerPrompt, contains('"excludedCapabilities":["camera"]'));
    expect(find.byKey(const ValueKey('creation-brief')), findsOneWidget);
    expect(find.byKey(const ValueKey('capability-camera')), findsNothing);
    expect(submissions, isEmpty);
    await tap(tester, find.text(appL10n.wishPlanStart));
    expect(submissions.single.capabilities, isNot(contains(WishCreationCapability.camera)));
    expect(submissions.single.excluded, contains(WishCreationCapability.camera));
    expect(deviceCalls, isEmpty);
    await dispose(tester);
  });

  testWidgets('edited preview is passed exactly with the original idea and clone source', (tester) async {
    const original = '做一个我的旅行清单，保持红色风格';
    const edited = '保留红色风格。\n只有打包清单和完成勾选，不加入账号或地图。';
    await show(
      tester,
      request: original,
      sourceId: 'local-source',
      complete: (_) async => response('AI 初稿', capabilities: ['storage']),
    );
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    await tester.enterText(find.byKey(const ValueKey('creation-brief')), edited);
    await tester.pump();
    expect(submissions, isEmpty);
    await tap(tester, find.text(appL10n.wishPlanStart));
    expect(submissions.single.request, original);
    expect(submissions.single.creationPlan, edited);
    expect(submissions.single.sourceId, 'local-source');
    expect(() => submissions.single.capabilities.add(WishCreationCapability.phone), throwsUnsupportedError);
    await dispose(tester);
  });

  testWidgets('returning to edit and changing the idea invalidates the earlier plan', (tester) async {
    var modelCalls = 0;
    await show(
      tester,
      request: '做一个笔记本',
      complete: (_) async {
        modelCalls++;
        return response('方案 $modelCalls');
      },
    );
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-brief'))).controller!.text, '方案 1');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('creation-request')), findsOneWidget);
    expect(find.text(appL10n.wishPlanView), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('creation-request')), '改成一个阅读打卡本');
    await tester.pump();
    // The old label may finish its short exit; it must no longer be actionable.
    expect(find.text(appL10n.wishPlanView).hitTestable(), findsNothing);
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(modelCalls, 2);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-brief'))).controller!.text, '方案 2');
    expect(submissions, isEmpty);
    await dispose(tester);
  });

  testWidgets('an AI-added ability can be removed after review and stays excluded on regeneration', (tester) async {
    var modelCalls = 0;
    await show(
      tester,
      request: '做一个小工具',
      complete: (_) async {
        modelCalls++;
        return response('方案 $modelCalls', capabilities: ['camera']);
      },
    );
    expect(chip(tester, 'camera').selected, isFalse);
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expectPreviewTag(tester, 'camera', appL10n.wishCamera);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(chip(tester, 'camera').selected, isTrue);
    await tap(tester, find.byKey(const ValueKey('capability-camera')));
    expect(chip(tester, 'camera').selected, isFalse);
    // The old label may finish its short exit; it must no longer be actionable.
    expect(find.text(appL10n.wishPlanView).hitTestable(), findsNothing);
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(modelCalls, 2);
    expect(find.byKey(const ValueKey('capability-camera')), findsNothing);
    await tap(tester, find.text(appL10n.wishPlanStart));
    expect(submissions.single.excluded, contains(WishCreationCapability.camera));
    expect(submissions.single.capabilities, isNot(contains(WishCreationCapability.camera)));
    await dispose(tester);
  });

  testWidgets('stopping the wait discards a late response without overwriting a new idea', (tester) async {
    final pending = Completer<String>();
    var calls = 0;
    await show(
      tester,
      request: '做一个旧想法',
      complete: (_) {
        calls++;
        return calls == 1 ? pending.future : Future.value(response('新想法方案'));
      },
    );
    await tester.runAsync(() async {
      await tester.tap(find.text(appL10n.wishPlanOptimize));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pump();
    // A pending model response intentionally keeps the progress indicator
    // active, so do not pumpAndSettle until cancellation.
    for (var i = 0; calls == 0 && i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(calls, 1);
    await tester.tap(find.text(appL10n.wishPlanStopWaiting));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('creation-request')), '做一个新的阅读本');
    await tester.pump();
    expect(find.text(appL10n.wishPlanWaiting), findsOneWidget);
    final direct = find.ancestor(of: find.text(appL10n.wishPlanDirect), matching: find.byType(TextButton));
    expect(tester.widget<TextButton>(direct).onPressed, isNull);
    await tester.tap(find.text(appL10n.wishPlanWaiting));
    await tester.pump();
    expect(calls, 1, reason: 'A pending model call is not started again after leaving the wait screen.');
    expect(submissions, isEmpty);
    pending.complete(response('过期方案'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('creation-brief')), findsNothing);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-request'))).controller!.text, '做一个新的阅读本');
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(calls, 2);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-brief'))).controller!.text, '新想法方案');
    expect(submissions, isEmpty);
    await dispose(tester);
  });

  testWidgets('model failure retains the idea and local fallback is explicitly labelled', (tester) async {
    const original = '做一个可保存的倒计时';
    await show(tester, request: original, complete: (_) async => throw StateError('MODEL_NOT_CONFIGURED'));
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-request'))).controller!.text, original);
    expect(find.byKey(const ValueKey('creation-brief')), findsNothing);
    expect(submissions, isEmpty);
    await tap(tester, find.text(appL10n.wishPlanUseLocal));
    expect(find.text(appL10n.wishPlanLocalReady), findsOneWidget);
    expect(find.text(appL10n.wishPlanAiReady), findsNothing);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-brief'))).controller!.text, contains(original));
    await tap(tester, find.text(appL10n.wishPlanStart));
    expect(submissions.single.request, original);
    expect(submissions.single.capabilities, contains(WishCreationCapability.reminders));
    await dispose(tester);
  });

  testWidgets('a failed regeneration keeps the edited plan available for confirmation', (tester) async {
    var calls = 0;
    await show(
      tester,
      request: '做一个专注工具',
      complete: (_) async {
        calls++;
        if (calls > 1) throw StateError('MODEL_FAILED');
        return response('模型的初稿');
      },
    );
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    const edited = '用户编辑后的方案：只有专注时间和休息时间，不增加社交功能。';
    await tester.enterText(find.byKey(const ValueKey('creation-brief')), edited);
    await tester.pump();
    await tap(tester, find.text(appL10n.wishPlanRegenerate));
    expect(calls, 2);
    expect(find.byKey(const ValueKey('creation-brief')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-brief'))).controller!.text, edited);
    expect(submissions, isEmpty);
    await tap(tester, find.text(appL10n.wishPlanStart));
    expect(submissions.single.creationPlan, edited);
    await dispose(tester);
  });

  testWidgets('direct creation preserves the unoptimized idea and explicit capability choices', (tester) async {
    var modelCalls = 0;
    await show(
      tester,
      request: '做一个本地笔记本',
      complete: (_) async {
        modelCalls++;
        return response('不应被调用');
      },
    );
    await tap(tester, find.text(appL10n.wishPlanDirect));
    expect(modelCalls, 0);
    expect(submissions, hasLength(1));
    expect(submissions.single.request, '做一个本地笔记本');
    expect(submissions.single.creationPlan, isNull);
    expect(submissions.single.capabilities, {WishCreationCapability.storage});
    expect(deviceCalls, isEmpty);
    await dispose(tester);
  });

  testWidgets('input and editable preview fit a phone viewport with a visible keyboard', (tester) async {
    tester.view.physicalSize = const Size(384, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await show(tester, request: '做一个本地记事本', complete: (_) async => response('一个可编辑的创作方案'));
    await tester.tap(find.byKey(const ValueKey('creation-request')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getBottomRight(find.text(appL10n.wishPlanOptimize)).dy, lessThanOrEqualTo(480));
    await tap(tester, find.text(appL10n.wishPlanOptimize));
    await tester.tap(find.byKey(const ValueKey('creation-brief')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.byType(AppBar)).dy, 0);
    expect(tester.getBottomRight(find.text(appL10n.wishPlanStart)).dy, lessThanOrEqualTo(480));
    await tester.enterText(find.byKey(const ValueKey('creation-brief')), '第一行\n第二行\n第三行');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const ValueKey('creation-brief'))).controller!.text, '第一行\n第二行\n第三行');
    expect(tester.takeException(), isNull);
    expect(submissions, isEmpty);
    await dispose(tester);
  });
  testWidgets('IME gives long requests a dedicated editor and preserves selection over repeated resizing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final request = List.generate(30, (i) => '第 $i 行：保留输入、光标和中文候选，不自动提交。').join('\n');
    await show(tester, request: request, complete: (_) async => response('方案'));
    final field = find.byKey(const ValueKey('creation-request'));
    await tester.tap(field);
    final controller = tester.widget<TextField>(field).controller!;
    const selection = TextSelection.collapsed(offset: 40);
    controller.selection = selection;
    for (final inset in [320.0, 0.0, 360.0, 0.0, 300.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field).controller, same(controller));
      expect(controller.text, request);
      expect(controller.selection, selection);
      expect(tester.takeException(), isNull);
      if (inset > 0) {
        expect(find.text(appL10n.wishNewTitle), findsNothing);
        expect(find.text(appL10n.wishIdeaPomodoro), findsNothing);
        expect(find.text(appL10n.wishPlanDirect), findsNothing);
        final editor = tester.getRect(field);
        final action = tester.getRect(find.byKey(const ValueKey('creation-compact-submit')));
        expect(editor.top, greaterThanOrEqualTo(tester.getBottomRight(find.byType(AppBar)).dy));
        expect(editor.bottom, lessThanOrEqualTo(action.top));
        expect(editor.height, greaterThan(220));
        expect(action.bottom, lessThanOrEqualTo(844 - inset));
      }
    }
    expect(submissions, isEmpty);
    await dispose(tester);
  });
}
