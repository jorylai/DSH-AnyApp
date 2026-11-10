import 'dart:convert';

import '../share_code/guest_fs.dart';

class WishProject {
  WishProject(Map<String, dynamic> json)
    : id = json['id'] as String,
      title = json['title'] as String,
      request = json['request'] as String? ?? '',
      sessionId = json['sessionId'] as String?,
      panel = json['panel'] as String?,
      createdAt = DateTime.tryParse('${json['createdAt'] ?? ''}'),
      published = json['state'] == 'published' {
    if (!RegExp(r'^local-[a-z0-9][a-z0-9-]{0,42}$').hasMatch(id)) throw const FormatException('invalid-project');
  }
  final String id, title, request;
  final String? sessionId, panel;
  final bool published;
  final DateTime? createdAt;
  String get profile => 'app-$id';
  static Future<List<WishProject>> local() async {
    final fs = await GuestFs.local();
    final file = fs?.file('/root/.dsh/wish/projects.json');
    if (file == null || !await file.exists()) return [];
    return (jsonDecode(await file.readAsString()) as List)
        .map((e) => WishProject((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
