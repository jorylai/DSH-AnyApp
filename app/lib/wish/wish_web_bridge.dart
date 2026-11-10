import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../l10n/l10n.dart';
import 'wish_form.dart';
import 'wish_device.dart';
import 'wish_agent.dart';
import 'wish_capabilities_page.dart';
import 'wish_models.dart';
import 'wish_actions.dart';
import 'wish_travel.dart';
import 'wish_jobs_page.dart';
import 'wish_icon_art.dart';

/// Bound to one work and one trusted top-level document. No general RPC,
/// credentials or private file paths are exposed to browser plugins.
class WishWebBridge {
  WishWebBridge({
    required this.projectId,
    required this.origin,
    required this.client,
    required this.context,
    required this.publish,
    this.capabilitiesChanged,
    this.openAgent,
    this.leave,
    this.metadataChanged,
  });
  final String projectId;
  final Uri origin;
  final DshClient client;
  final BuildContext Function() context;
  final Future<Object?> Function(Map<String, dynamic>) publish;
  final Future<void> Function()? capabilitiesChanged;
  final Future<void> Function(String)? openAgent;
  final Future<void> Function()? leave;
  final Future<void> Function()? metadataChanged;
  Future<void> Function()? settings;
  bool ready = false;
  VoidCallback? onReady;
  VoidCallback? onLoading;
  Future<bool> openSettings() async {
    final c = _controller;
    if (c == null) return false;
    return (await c.runJavaScriptReturningResult("Boolean(window.__dshWishSettings && window.__dshWishSettings())"))
            .toString() ==
        "true";
  }

  late final agent = WishAgent(projectId, client);
  WebViewController? _controller;
  String _nonce = '';
  int _epoch = 0;
  bool _busy = false, _disposed = false;
  void invalidate() {
    final wasReady = ready;
    ready = false;
    if (!_disposed && wasReady) onLoading?.call();
    _epoch++;
    _nonce = base64UrlEncode(List.generate(24, (_) => Random.secure().nextInt(256)));
  }

  void detach(WebViewController controller) {
    if (_controller == controller) {
      invalidate();
      _controller = null;
    }
  }

  void dispose() {
    _disposed = true;
    agent.dispose();
    invalidate();
    _controller = null;
  }

  Future<void> attach(WebViewController controller) async {
    invalidate();
    _controller = controller;
    await controller.addJavaScriptChannel(
      'DshWish',
      onMessageReceived: (m) => unawaited(_message(controller, m.message)),
    );
  }

  static bool sameOrigin(Uri expected, String? raw) {
    final url = Uri.tryParse(raw ?? '');
    return url != null && url.scheme == expected.scheme && url.host == expected.host && url.port == expected.port;
  }

  Future<void> inject(WebViewController controller) async {
    if (_disposed || controller != _controller || !sameOrigin(origin, await controller.currentUrl())) return;
    final source = await rootBundle.loadString('assets/web/dsh_wish.js');
    final style = await rootBundle.loadString('assets/design-kit/wish.css');
    await controller.runJavaScript(
      '($source)(${jsonEncode({'nonce': _nonce, 'projectId': projectId, 'locale': appL10n.localeName, 'styleCss': style})});',
    );
  }

  Future<bool> _confirm(String title, String body) async {
    final ctx = context();
    if (!ctx.mounted) return false;
    return await showDialog<bool>(
          context: ctx,
          builder: (dialog) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(appL10n.wishKeep)),
              FilledButton(onPressed: () => Navigator.pop(dialog, true), child: Text(appL10n.wishBridgeAllow)),
            ],
          ),
        ) ==
        true;
  }

  Future<void> _message(WebViewController controller, String text) async {
    if (_disposed || controller != _controller || text.length > 3000000) return;
    Map<String, dynamic> message;
    try {
      message = wishMap(jsonDecode(text));
    } catch (_) {
      return;
    }
    final epoch = _epoch;
    if (message['nonce'] != _nonce ||
        message['id'] is! String ||
        (message['id'] as String).length > 100 ||
        !sameOrigin(origin, await controller.currentUrl()))
      return;
    if (_disposed || epoch != _epoch || controller != _controller) return;
    Object? value;
    String? error;
    var ownsBusy = false;
    try {
      // React can mount two consumers of persisted state at once. Only
      // interactive capabilities need an exclusive dialog/camera lease;
      // the backend already serializes data writes in the work namespace.
      if ({
        'camera.capture',
        'project.publish',
        'phone.begin',
        'agent.start',
        'capabilities.request',
      }.contains(message['method'])) {
        if (_busy) throw StateError(appL10n.wishBusy);
        _busy = true;
        ownsBusy = true;
      }
      final args = wishMap(message['args'] ?? <String, dynamic>{});
      switch (message['method']) {
        case 'icons.render':
          value = await WishIconArt.render(args);
        case 'background.open':
          final ctx = context();
          if (ctx.mounted)
            await Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => WishJobsPage(
                  work: projectId,
                  title: args['title'] as String? ?? '',
                  prompt: args['prompt'] as String? ?? '',
                  phone: args['phone'] == true,
                ),
              ),
            );
          value = true;
        case 'background.schedule':
        case 'background.list':
        case 'background.cancel':
        case 'background.runNow':
          value = await WishDevice.call(message['method'] as String, work: projectId, args: args);
        case 'travel.extract':
          value = await WishTravel.extract(
            client,
            args['text'] as String? ?? '',
            image: args['image'] == null ? null : wishMap(args['image']),
          );
        case 'travel.remove':
          await WishTravel.remove(client, projectId, args['id'] as String);
          value = {'removed': true};
        case 'travel.list':
          value = await client.rpc.call('wishMobile/travelList', {});
        case 'travel.save':
          value = await WishTravel.save(
            client,
            projectId,
            wishMap(args['entry']),
            calendar: args['calendar'] == true,
            reminder: args['reminder'] == true,
          );
        case 'imports.read':
        case 'imports.list':
        case 'imports.remove':
        case 'shortcuts.pin':
        case 'widget.pin':
        case 'widget.update':
        case 'life.status':
        case 'calendar.list':
        case 'calendar.save':
        case 'calendar.delete':
        case 'notifications.list':
        case 'files.pick':
        case 'files.export':
        case 'speech.listen':
        case 'speech.speak':
        case 'speech.stop':
        case 'location.once':
        case 'maps.open':
        case 'ocr.recognize':
          value = await WishDevice.call(message['method'] as String, work: projectId, args: args);
        case 'actions.show':
        case 'actions.hide':
          value = await WishDevice.call(message['method'] as String, work: projectId);
        case 'actions.run':
          value = await WishActions.run(projectId, args['id'] as String);
        case 'work.identity':
          value = await WishDevice.call('works.get', work: projectId);
        case 'work.describe':
          value = await WishDevice.call('works.describe', work: projectId, args: {'value': args['value']});
          await metadataChanged?.call();
        case 'actions.register':
          value = await WishDevice.call(
            'works.describe',
            work: projectId,
            args: {
              'value': {'actions': args['actions']},
            },
          );
        case 'ui.ready':
          ready = true;
          onReady?.call();
          value = true;
        case 'capabilities.status':
          value = await WishDevice.status(projectId);
        case 'capabilities.request':
          await Navigator.of(context())
              .push(MaterialPageRoute<void>(builder: (_) => WishCapabilitiesPage(projectId: projectId)));
          await capabilitiesChanged?.call();
          value = await WishDevice.status(projectId);
        case 'phone.tools':
          value = await WishDevice.call('phone.tools', work: projectId);
        case 'phone.begin':
        case 'agent.start':
          final prompt = args['prompt'];
          if (prompt is! String || prompt.trim().isEmpty || prompt.length > 10000)
            throw StateError('invalid-agent-request');
          if (_disposed || epoch != _epoch) throw StateError(appL10n.wishBridgeCancelled);
          if (message['method'] == 'agent.start')
            value = await agent.start(prompt, requiresPhone: args['phone'] != false);
          else
            value = await WishDevice.call('phone.begin', work: projectId);
        case 'phone.call':
          value = await WishDevice.call(
            'phone.call',
            work: projectId,
            args: {'ticket': args['ticket'], 'tool': args['tool'], 'args': args['args'] ?? {}},
          );
        case 'phone.end':
          value = await WishDevice.call('phone.end', work: projectId);
        case 'phone.pause':
          value = await WishDevice.call('phone.pause', work: projectId, args: {'paused': args['paused'] == true});
        case 'agent.results':
          value = await client.rpc.call('wishMobile/agentResults', {});
        case 'agent.open':
          final session = await agent.session;
          if (session != null) await openAgent?.call(session);
          value = session != null;
        case 'agent.status':
          value = await agent.status();
        case 'agent.steer':
          await agent.steer(args['text'] as String);
          value = true;
        case 'agent.stop':
          await agent.stop();
          value = true;
        case 'reminders.schedule':
          value = await WishDevice.call(
            'reminders.schedule',
            work: projectId,
            args: {
              'id': args['id'],
              'at': args['at'],
              'title': args['title'],
              'body': args['body'] ?? '',
              'repeat': args['repeat'] ?? 'none',
              if (args['timeZone'] != null) 'timeZone': args['timeZone'],
            },
          );
        case 'reminders.list':
          value = await WishDevice.call('reminders.list', work: projectId);
        case 'reminders.cancel':
          value = await WishDevice.call('reminders.cancel', work: projectId, args: {'id': args['id']});
        case 'camera.capture':
          if (!await _confirm(appL10n.wishCamera, appL10n.wishBridgeCameraHelp)) break;
          if (_disposed || epoch != _epoch) throw StateError(appL10n.wishBridgeCancelled);
          final photo = await ImagePicker().pickImage(
            source: ImageSource.camera,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 80,
          );
          if (photo != null) {
            final bytes = await photo.readAsBytes();
            if (bytes.length > 2000000) throw StateError(appL10n.wishBridgeImageLarge);
            value = {'data': base64Encode(bytes), 'mediaType': 'image/jpeg'};
          }
        case 'ai.complete':
          final prompt = args['prompt'];
          if (prompt is! String || prompt.trim().isEmpty || prompt.length > 40000)
            throw StateError('invalid-ai-request');
          // The user chose direct model requests. Keep route checks and stale-document protection.
          await WishModels.ready(client);
          if (_disposed || epoch != _epoch) throw StateError(appL10n.wishBridgeCancelled);
          value = await WishModels.complete(
            client,
            prompt,
            image: args['image'] == null ? null : wishMap(args['image']),
          );
        case 'data.read':
          value = await client.rpc.call('wishMobile/read', {'collection': args['collection']});
        case 'data.write':
          value = await client.rpc.call('wishMobile/write', {'collection': args['collection'], 'value': args['value']});
        case 'project.publish':
          value = await publish(args);
        default:
          throw StateError(appL10n.wishUnsupported);
      }
    } catch (e) {
      error = wishErrorText(e);
    } finally {
      if (ownsBusy) _busy = false;
    }
    if (_disposed || _epoch != epoch || controller != _controller || !sameOrigin(origin, await controller.currentUrl()))
      return;
    try {
      await controller.runJavaScript(
        'window.__dshWishReply && window.__dshWishReply(${jsonEncode({'nonce': _nonce, 'id': message['id'], 'ok': error == null, 'value': value, 'error': error})});',
      );
    } catch (_) {}
  }
}
