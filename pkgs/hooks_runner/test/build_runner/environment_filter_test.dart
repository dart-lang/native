// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks_runner/hooks_runner.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() {
  test('hooks have access to http proxy variable', () async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    server.listen((request) async {
      expect(request.headers.host, 'testing_proxy.dart.dev');
      expect(request.uri.path, '/test_asset');

      final response = request.response;
      response.statusCode = 200;
      response.writeln('test body response');
      await response.close();
    });

    addTearDown(server.close);
    final port = server.port;

    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('download_assets/');
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final result = await runProcess(
        executable: dartExecutable,
        arguments: [
          pkgNativeAssetsBuilderUri
              .resolve('test/build_runner/concurrency_shared_test_helper.dart')
              .toFilePath(),
          packageUri.toFilePath(),
          Target.current.toString(),
        ],
        workingDirectory: packageUri,
        logger: logger,
        environment: {'HTTP_PROXY': 'localhost:$port'},
      );
      expect(result.exitCode, 0);
    });
  });
}
