// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('wrong asset id', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('wrong_namespace_asset/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        var buildFailed = false;
        final assets = await build(packageUri, logger, dartExecutable)
            .onError((error, stackTrace) {
          buildFailed = true;
          return [];
        });
        expect(buildFailed, true);
        expect(assets, <Asset>[]);
      }
    });
  });
}
