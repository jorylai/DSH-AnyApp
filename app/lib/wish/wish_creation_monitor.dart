import 'dart:async';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import 'wish_device.dart';
import 'wish_form.dart';

class WishCreationState {
  const WishCreationState(this.phase, {this.ready = false});
  final String phase;
  final bool ready;
}

class WishCreationMonitor {
  WishCreationMonitor._(this.work, this.session, this.client);
  final String work, session;
  final DshClient client;
  final state = ValueNotifier(const WishCreationState('waiting'));
  Timer? _timer;
  StreamSubscription<HostEvent>? _events;
  bool _busy = false, _seenRunning = false;
  static final _all = <String, WishCreationMonitor>{};
  static WishCreationMonitor watch(String work, String session, DshClient client, {bool fresh = false}) {
    final old = _all[work];
    if (old != null && old.session == session && identical(old.client, client)) {
      if (fresh) old._seenRunning = true;
      return old;
    }
    old?._timer?.cancel();
    old?._events?.cancel();
    final monitor = _all[work] = WishCreationMonitor._(work, session, client);
    monitor._seenRunning = fresh;
    monitor._events = client.hostEvents.listen(
      (e) {
        if (e is SessionStatusEvent && e.sessionId == session) monitor._poll();
      },
      onError: (_) {},
      onDone: () => monitor._timer?.cancel(),
    );
    monitor._poll();
    monitor._timer = Timer.periodic(const Duration(seconds: 30), (_) => monitor._poll());
    return monitor;
  }

  static void forget(String work) {
    final old = _all.remove(work);
    old?._timer?.cancel();
    old?._events?.cancel();
  }

  Future<void> _poll() async {
    if (_busy) return;
    _busy = true;
    try {
      final rows = await client.listSessions();
      final row = rows.where((s) => s.sessionId == session).firstOrNull;
      if (row == null) {
        state.value = const WishCreationState('interrupted');
        return;
      }
      if (row.running) {
        _seenRunning = true;
        state.value = const WishCreationState('running');
        return;
      }
      final projection = await client.projections(session);
      final page = wishMap(
        await client.rpc.call('session/page', {
          'request': {
            'address': {'kind': 'session', 'sessionId': session},
            'throughSeq': projection?.asOfSeq ?? 0,
            'maxMessages': 12,
          },
        }),
      );
      final phase = creationPhase(wishMap(page));
      final bundles = phase == 'succeeded' ? await client.listBundles() : <PluginBundle>[];
      final installed = bundles.any((b) => b.name == '@local/$work' && b.installed && b.enabled && b.error == null);
      state.value = WishCreationState(phase, ready: phase == 'succeeded' && installed);
      if (phase == 'succeeded' && installed) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'wish.creation.notified:$session';
        final seq = projection?.asOfSeq ?? 0;
        if (_seenRunning && prefs.getInt(key) != seq) {
          final delivery = wishMap(
            await WishDevice.call(
              'events.notify',
              work: work,
              args: {'title': appL10n.wishReadyOpen, 'message': appL10n.wishCreationNotification},
            ),
          );
          if (delivery['posted'] == true) await prefs.setInt(key, seq);
        }
      }
    } catch (_) {
      /* A disconnected runtime must never be reported as a completed creation. */
    } finally {
      _busy = false;
    }
  }
}

String creationPhase(Map<String, dynamic> page) {
  var phase = 'interrupted';
  for (final raw in page['records'] as List? ?? []) {
    final e = wishMap(wishMap(raw)['event']);
    if (e['type'] == 'turn/start') phase = 'running';
    if (e['type'] == 'turn/end') {
      final reason = wishMap(wishMap(e['data'] ?? {})['reason'] ?? {});
      phase = switch (reason['kind']) {
        'completed' => 'succeeded',
        'aborted' => 'stopped',
        'blocked' => 'awaiting-confirmation',
        'error' || 'max-tokens' => 'failed',
        _ => 'interrupted',
      };
    }
  }
  return phase;
}
