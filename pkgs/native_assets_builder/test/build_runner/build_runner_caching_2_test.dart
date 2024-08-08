// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test(
    'add C file, modify hook',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('native_add/');

        await runPubGet(workingDirectory: packageUri, logger: logger);
        // Make sure the first compile is at least one second after the
        // package_config.json is written, otherwise dill compilation isn't
        // cached.
        await Future<void>.delayed(const Duration(seconds: 1));

        final result = await build(packageUri, logger, dartExecutable);
        final assetFile = File.fromUri(result.assets.single.file!);
        final lastModified = await assetFile.lastModified();
        final fileSize = (await assetFile.readAsBytes()).length;
        await expectSymbols(
          asset: result.assets.single as NativeCodeAssetImpl,
          symbols: ['add'],
        );

        await copyTestProjects(
          sourceUri: testDataUri.resolve('native_add_add_source/'),
          targetUri: packageUri,
        );

        {
          final result = await build(packageUri, logger, dartExecutable);
          final lastModified2 = await assetFile.lastModified();
          expect(lastModified2, isNot(lastModified));
          final fileSize2 = (await assetFile.readAsBytes()).length;
          expect(fileSize2, isNot(fileSize));
          await expectSymbols(
            asset: result.assets.single as NativeCodeAssetImpl,
            symbols: ['add', 'multiply'],
          );
        }
      });
    },
  );
}
