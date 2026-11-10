import 'dart:convert';
import 'dart:typed_data';

import 'package:dsh_client/dsh_client.dart';

import 'wish_form.dart';
import 'wish_food_ai.dart';

/// Model identity and OAuth stay in the running DSH, including official
/// account login. The phone never extracts an account grant as an API key.
class WishModels {
  static Future<Map<String, dynamic>> ready(DshClient client) async {
    try {
      await client.rpc.call('session/initializeDefaultModel');
    } on DshRemoteException catch (e) {
      if (e.code != 'session/provider-models-unavailable') rethrow;
    }
    final status = wishMap(await client.rpc.call('wishMobile/modelStatus'));
    if (status['ready'] != true) throw StateError('${status['code'] ?? 'MODEL_NOT_CONFIGURED'}');
    return status;
  }

  static Future<Map<String, dynamic>> complete(DshClient client, String prompt, {Map<String, dynamic>? image}) async =>
      wishMap(
        await client.rpc.call('wishMobile/complete', {
          'request': {'prompt': prompt, if (image != null) 'image': image},
        }, const Duration(seconds: 110)),
      );

  static Future<FoodRecognition> food(
    DshClient client,
    Uint8List bytes, {
    required String namespace,
    required bool uploadConsent,
  }) async {
    final route = await ready(client);
    return FoodVision.recognize(
      jpeg: bytes,
      namespace: namespace,
      uploadConsent: uploadConsent,
      model: '${route['provider']}/${route['model']}',
      complete: (prompt, jpeg) async =>
          (await complete(client, prompt, image: {'data': base64Encode(jpeg), 'mediaType': 'image/jpeg'}))['text']
              as String,
    );
  }
}
