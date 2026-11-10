import 'package:dsh_app/state/artifacts.dart';
import 'package:dsh_app/ui/share/share_export.dart';
import 'package:dsh_app/ui/share_code/share_out.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dsh/files');
  const files = FilesChannel(channel);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('new image and portable share names use AnyApp while retaining their compatible extensions', () {
    final now = DateTime(2026, 11, 10, 13, 4, 5);
    final image = ShareExporter(files: files, clock: () => now);
    final portable = ShareOut(files: files, clock: () => now);
    expect(image.fileName(), 'dsh-anyapp-20261110-130405.png');
    expect(portable.fileName(profile: true), 'dsh-anyapp-profile-20261110.dshgo');
    expect(portable.fileName(profile: false, name: '@example/notes'), 'dsh-anyapp-plugin-notes.dshgo');
    expect(portable.fileName(profile: false, name: ''), 'dsh-anyapp-plugin-plugin.dshgo');
  });

  test('new export fallback uses the AnyApp folder and preserves the requested file name', () async {
    MethodCall? recorded;
    messenger.setMockMethodCallHandler(channel, (call) async {
      recorded = call;
      return null;
    });
    expect(phoneOutputDir, '/sdcard/Download/DSH-AnyApp');
    expect(
      await files.saveToDownloads('/private/report.pdf', name: '我的报告.pdf', mime: 'application/pdf'),
      'Download/DSH-AnyApp/我的报告.pdf',
    );
    expect(recorded!.method, 'saveToDownloads');
    expect(recorded!.arguments, {'path': '/private/report.pdf', 'name': '我的报告.pdf', 'mime': 'application/pdf'});
  });

  test('a native saved location is returned verbatim, including old files or collision renaming', () async {
    for (final path in ['Download/DSH-Go/report.pdf', 'Download/DSH-AnyApp/report (1).pdf']) {
      messenger.setMockMethodCallHandler(channel, (_) async => path);
      expect(await files.saveToDownloads('/private/report.pdf', name: 'report.pdf', mime: 'application/pdf'), path);
    }
  });

  test('output metadata from current and historical directories remains available', () async {
    final paths = ['DSH-AnyApp', 'DSH-Go', 'DSH'].map((folder) => '/sdcard/Download/$folder/report.pdf').toList();
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'listOutputs');
      expect(call.arguments, {'depth': 3});
      return [
        for (var i = 0; i < paths.length; i++) {'path': paths[i], 'bytes': i + 10, 'modified': 1000 + i},
      ];
    });
    final outputs = await files.listOutputs();
    expect(outputs.map((file) => file.path), paths);
    expect(outputs.map((file) => file.bytes), [10, 11, 12]);
    expect(outputs.map((file) => file.modified.millisecondsSinceEpoch), [1000, 1001, 1002]);
    for (final path in paths) {
      expect(Artifact(path: path, origin: ArtifactOrigin.phoneOutput, turn: 1).inPhoneDownloads, isTrue);
    }
  });
}
