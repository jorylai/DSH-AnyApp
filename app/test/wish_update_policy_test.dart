import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/update/update_config.dart';
void main() {
  test('unconfigured AnyApp updates never fall back to upstream releases', () {
    final sources = defaultUpdateSources();
    expect(sources.useGithubApi, false);
    expect(sources.channel, isNull);
    expect(sources.mirrors, isEmpty);
    if (anyappUpdateFeedUri == null) expect(sources.metadataEndpoints(), isEmpty);
    expect(sources.downloadUrls([githubLatestAsset('test.apk')]), isEmpty);
  });
}
