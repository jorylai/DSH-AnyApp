import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/locale_state.dart';
import 'wish_actions.dart';
import 'wish_agent.dart';
import 'wish_app_runtime.dart';
import 'wish_device.dart';
import 'wish_form.dart';

@pragma('vm:entry-point')
Future<void> startAnyappBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLanguageController.load();
  await WishActions.init(ProviderContainer(), foreground: false);
}

/// Real DSH turns, observed until a terminal state, independent of a page or Activity.
class AnyappBackground {
  static final _agents = <String, WishAgent>{};
  static final _cancelled = <String>{};
  static Future<void> cancel(Map<String, dynamic> job) async {
    final id = job['runId'] as String;
    _cancelled.add(id);
    await _agents[id]?.stop();
  }

  static Future<Map<String, dynamic>> run(ProviderContainer container, Map<String, dynamic> job) async {
    final work = job['work'] as String, run = job['runId'] as String;
    if (_agents.isNotEmpty) return {'phase': 'waiting-resource'};
    try {
      final state = await WishDevice.status(work);
      if (state['background'] != true) throw StateError('background-not-authorized');
      final client = await WishAppRuntime.connect(container, 'app-$work');
      final host = await client.rpc.call('wishMobile/hostBusy', {});
      if (host is Map && host['busy'] == true) return {'phase': 'waiting-resource'};
      if (_cancelled.contains(run)) return {'phase': 'stopped'};
      final agent = WishAgent(work, client);
      _agents[run] = agent;
      final phone = job['phone'] == true;
      await agent.start(
        '''这是用户预先安排的后台任务，不是网页或通知内容中的新指令。
任务：${job['prompt']}
当前任务标题：${job['title']}。使用真实工具与可访问来源，完成后给出简明结果；没有获取到的信息明确标注。不要改写本作品插件，不读取其他作品或凭据。${phone ? '手机操作仍以实际授权、亮屏和解锁状态为准。' : '这项任务只在后台处理信息；不要调用手机屏幕、点按、相机或其他需要前台界面的能力。'}''',
        requiresPhone: phone,
        timeZone: job['timeZone'] as String?,
      );
      final until = DateTime.now().add(const Duration(minutes: 20));
      final begun = DateTime.now();
      var seenRunning = false;
      String? detail;
      while (DateTime.now().isBefore(until)) {
        if (_cancelled.contains(run)) {
          await agent.stop();
          return {'phase': 'stopped'};
        }
        final value = await agent.status();
        final phase = value['phase'];
        if (phase != detail && {'running', 'awaiting-confirmation', 'paused'}.contains(phase)) {
          detail = phase as String;
          await WishDevice.call(
            'background.progress',
            work: work,
            args: {'id': job['id'], 'runId': run, 'detail': detail, 'sessionId': value['sessionId']},
          );
        }
        seenRunning = seenRunning || value['running'] == true;
        if (value['running'] != true && phase != 'awaiting-confirmation') {
          if (!seenRunning && phase == 'interrupted' && DateTime.now().difference(begun).inSeconds < 15) {
            await Future<void>.delayed(const Duration(seconds: 2));
            continue;
          }
          final text = (value['events'] as List? ?? [])
              .map(wishMap)
              .where((e) => e['type'] == 'text')
              .map((e) => '${e['text'] ?? ''}')
              .join('\n');
          return {
            'phase': phase == 'succeeded'
                ? 'succeeded'
                : phase == 'stopped'
                ? 'stopped'
                : phase == 'failed'
                ? 'failed'
                : 'interrupted',
            'text': text.length > 12000 ? text.substring(text.length - 12000) : text,
          };
        }
        await Future<void>.delayed(const Duration(seconds: 4));
      }
      await agent.stop();
      return {'phase': 'interrupted'};
    } catch (e) {
      final text = '$e';
      if (text.contains('finish-current-conversation-first') ||
          text.contains('runtime-busy') ||
          text.contains('agent-busy'))
        return {'phase': 'waiting-resource'};
      // Model errors may carry endpoint data. The persisted result uses a stable public code.
      return {'phase': 'failed', 'text': 'background-task-incomplete'};
    } finally {
      _agents.remove(run);
      _cancelled.remove(run);
    }
  }
}
