import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final file = File.fromUri(input.outputDirectory.resolve('testfile'));

    final client = HttpClient()
      ..findProxy = HttpClient.findProxyFromEnvironment;
    // This request should fail outside of proxies.
    final request = await client.get(
      'testing_proxy.dart.dev',
      80,
      'test_asset',
    );
    final response = await request.close();

    if (response.statusCode != 200) {
      throw Exception('Could not fetch asset');
    }

    await response.pipe(file.openWrite());

    output.assets.code.add(
      CodeAsset(
        package: 'download_assets',
        name: 'testing',
        linkMode: DynamicLoadingBundled(),
        file: file.uri,
      ),
    );
  });
}
