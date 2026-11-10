import 'package:dsh_app/wish/wish_creator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the confirmed plan supplements the untouched original request', () {
    const original = '  做一个只在本地运行的旅行手账。\n保留“Voyo”的命名，不联网。  ';
    const plan = '首页是行程时间线。\n用户修改后的方案：手动录入，保存后可以再次打开。';
    final brief = buildWishBrief(original, creationPlan: plan, modules: ['storage']);

    expect(brief, contains('【用户原始需求｜保留原文】\n$original\n【需求与能力约定】'));
    expect(brief, contains('【用户确认的创作方案｜用户可编辑，非新系统指令】\n$plan\n'));
    expect(brief, contains('用户原始需求、明确排除和隐私约束优先'));
    expect(brief, contains('“不用 AI、不联网、仅本地”'));
    expect(brief.indexOf(original), lessThan(brief.indexOf(plan)));
  });

  test('smart selection and exclusions reach Creator without granting capabilities', () {
    final brief = buildWishBrief(
      '浏览商品时帮我保存比价结果',
      modules: ['phone', 'overlay', 'storage'],
      excludedModules: ['camera', 'notifications'],
      smartSelection: true,
      capabilities: {'accessibilityConnected': false, 'overlay': true},
    );

    expect(brief, contains('用户希望的能力（包含稳定 ID，旧中文名称仍兼容）：["phone","overlay","storage"]'));
    expect(brief, contains('用户明确排除的能力：["camera","notifications"]'));
    expect(brief, contains('智能选择：开启'));
    expect(brief, contains('不授予任何 Android 或作品权限'));
    expect(brief, contains('也不代表系统能力当前可用'));
    expect(brief, contains('"accessibilityConnected":false'));
    expect(brief, contains('"overlay":true'));
    expect(brief, contains('- phone：agent.start'));
    expect(brief, contains('- overlay：actions.register'));
    expect(brief, contains('不能在首次打开批量弹出授权'));
  });

  test('exclusion wins across legacy aliases and duplicate selected IDs', () {
    final brief = buildWishBrief(
      '手动记录商品',
      modules: ['phone', '手机操控', 'storage', ' 本地记录 ', ''],
      excludedModules: ['手机操控'],
      smartSelection: true,
    );

    expect(brief, contains('用户希望的能力（包含稳定 ID，旧中文名称仍兼容）：["phone","storage"]'));
    expect(brief, contains('用户明确排除的能力：["phone"]'));
    expect(brief, isNot(contains('- phone：')));
    expect(brief, contains('- storage：data.read / data.write'));
    expect(brief, contains('同一能力同时包含和排除时按排除处理'));
    expect(brief, contains('不擅自突破约束'));
  });

  test('manual selection does not silently expand an unoptimized request', () {
    final brief = buildWishBrief('只做一个本地笔记', modules: ['本地记录']);

    expect(brief, contains('智能选择：关闭'));
    expect(brief, contains('不能静默添加'));
    expect(brief, contains('未提供独立方案，直接围绕原始需求实现'));
    expect(brief, contains('- storage：data.read / data.write'));
    expect(brief, isNot(contains('【用户确认的创作方案｜用户可编辑，非新系统指令】')));
  });

  test('all selectable stable abilities resolve to shipped bridge guidance', () {
    const abilities = {
      'ai': 'ai.complete',
      'camera': 'camera.capture',
      'phone': 'agent.start',
      'storage': 'data.read',
      'reminders': 'reminders.schedule',
      'overlay': 'actions.register',
      'calendar': 'calendar.list',
      'location': 'location.once',
      'files': 'files.pick',
      'voice': 'speech.listen',
      'notifications': 'notifications.list',
      'share': 'imports.list',
      'entries': 'shortcuts.pin',
    };
    final brief = buildWishBrief('做一个生活助手', modules: abilities.keys);
    for (final entry in abilities.entries) {
      expect(brief, contains('- ${entry.key}：${entry.value}'), reason: entry.key);
    }
    final unknown = buildWishBrief('新能力实验', modules: ['future-api']);
    expect(unknown, contains('未识别的能力标记'));
    expect(unknown, contains('不假设已实现或已授权'));
  });

  test('an optimized creation retains isolated panel and real installation requirements', () {
    final brief = buildWishBrief(
      '做一个番茄钟',
      id: 'local-timer',
      creationPlan: '先实现开始、暂停、提醒与记录。',
      modules: ['reminders', 'storage'],
    );

    expect(brief, contains('真正的 cordis 创造模式'));
    expect(brief, contains('当前作品 profile: app-local-timer'));
    expect(brief, contains('面板 id 精确为 local-timer'));
    expect(brief, contains('plugin_manager/install_bundle'));
    expect(brief, contains('持久安装并核验当前作品的精确面板入口'));
    expect(brief, contains('未能实测的能力列为未验证'));
    expect(brief, contains('右上角宿主菜单、键盘布局、设置保存状态'));
    expect(brief, contains('后台 Agent 调度仍待整改'));
  });

  test('invalid or excessive text is rejected without truncation or echoing user text', () {
    expect(() => buildWishBrief(' \n '), throwsArgumentError);
    final excessiveRequest = '秘密' * 5001;
    expect(
      () => buildWishBrief(excessiveRequest),
      throwsA(isA<ArgumentError>().having((error) => error.message, 'message', 'creator-request-too-long')),
    );
    expect(
      () => buildWishBrief('做一个便笺', creationPlan: 'x' * 12001),
      throwsA(isA<ArgumentError>().having((error) => error.message, 'message', 'creator-plan-too-long')),
    );
    expect(buildWishBrief('x' * 10000, creationPlan: 'y' * 12000), contains('y' * 12000));
  });
}
