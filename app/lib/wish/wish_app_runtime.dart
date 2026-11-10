import 'dart:async';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../runtime/runtime_bridge.dart';
import '../runtime/runtime_state.dart';
import '../state/connection_state.dart';
import '../state/hosts_state.dart';
import 'wish_composition.dart';
import 'wish_engine_presentation.dart';

/// Native readiness, profile identity and authenticated connection must agree.
class WishAppRuntime {
  static Future<void> _queue = Future.value();

  static Future<DshClient> connect(ProviderContainer container, String profile, {bool restart = false}) {
    final task = _queue.then((_) => _connect(container, profile, restart));
    _queue = task.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return task;
  }

  static Future<DshClient> _connect(ProviderContainer container, String profile, bool restart) async {
    if (!RegExp(r'^[a-z0-9][a-z0-9-]{0,63}$').hasMatch(profile)) throw StateError('invalid-profile');
    final current = await container.read(runtimeBridgeProvider).status();
    if ((restart || current.profile != profile) && current.isRunning) {
      final connection = await container.read(localConnectionProvider.future);
      if (connection == null) throw StateError('runtime-busy-unverified');
      if ((await connection.client.listSessions()).any((s) => s.running)) {
        throw StateError('finish-current-conversation-first');
      }
      final busy = await connection.client.rpc.call('wishMobile/hostBusy', {});
      if (busy is Map && busy['busy'] == true) throw StateError('finish-current-conversation-first');
    }
    container.read(activeHostProvider.notifier).select(HostRef.local);
    container.read(localRuntimeProfileProvider.notifier).select(profile);
    final bridge = container.read(runtimeBridgeProvider);
    final runtime = container.read(localRuntimeProvider.notifier);
    var status = await bridge.status();
    debugPrint('WISH switch target=$profile current=${status.profile} phase=${status.phase.name}');
    if (status.phase == RuntimePhase.notInstalled || status.phase == RuntimePhase.installing)
      throw StateError('runtime-not-installed');
    if (status.inSafeMode) throw StateError('runtime-in-safe-mode');
    if (restart || status.profile != profile || !status.isRunning) {
      if ({RuntimePhase.running, RuntimePhase.starting, RuntimePhase.stopping}.contains(status.phase)) {
        await runtime.stop();
        debugPrint('WISH stopping profile=${status.profile}');
        final until = DateTime.now().add(const Duration(seconds: 25));
        do {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          status = await bridge.status();
          if ({RuntimePhase.installed, RuntimePhase.error}.contains(status.phase)) break;
          if (DateTime.now().isAfter(until)) throw TimeoutException('runtime-stop-timeout');
        } while (true);
      }
      await runtime.start(profile: profile);
      debugPrint('WISH start requested profile=$profile');
      final until = DateTime.now().add(const Duration(seconds: 90));
      do {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        status = await bridge.status();
        if (status.phase == RuntimePhase.error) throw StateError('runtime-start-failed');
        if (status.isRunning && status.profile == profile && !status.inSafeMode) break;
        if (DateTime.now().isAfter(until)) throw TimeoutException('runtime-start-timeout');
      } while (true);
    }
    final until = DateTime.now().add(const Duration(seconds: 30));
    debugPrint('WISH native ready profile=${status.profile}');
    do {
      final connection = await container.read(localConnectionProvider.future);
      final observed = container.read(localRuntimeProvider).status;
      if (connection != null && observed.token == status.token && observed.profile == profile) {
        await connection.client.mux.ready();
        await WishEnginePresentation.prepare(connection.client);
        return connection.client;
      }
      if (DateTime.now().isAfter(until)) throw TimeoutException('runtime-connect-timeout');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    } while (true);
  }

  static Future<bool> activate(BuildContext context, WishComposition form) async {
    await connect(ProviderScope.containerOf(context, listen: false), form.profile);
    return true;
  }
}
