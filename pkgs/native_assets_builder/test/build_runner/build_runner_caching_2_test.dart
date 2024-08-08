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

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        await runPubGet(workingDirectory: packageUri, logger: logger);
        // Make sure the first compile is at least one second after the
        // package_config.json is written, otherwise dill compilation isn't
        // cached.
        await Future<void>.delayed(const Duration(seconds: 1));
        logMessages.clear();

        final hookFile = File.fromUri(packageUri.resolve('hook/build.dart'));
        final hookFileLastModified = await hookFile.lastModified();

        final result = await build(packageUri, logger, dartExecutable);
        {
          final compiledHook = logMessages
              .where((m) => m.contains('dart compile kernel'))
              .isNotEmpty;
          expect(compiledHook, isTrue);
        }
        logMessages.clear();

        final assetFile = File.fromUri(result.assets.single.file!);
        final assetFileLastModified = await assetFile.lastModified();
        final fileSize = (await assetFile.readAsBytes()).length;
        await expectSymbols(
          asset: result.assets.single as NativeCodeAssetImpl,
          symbols: ['add'],
        );

        await copyTestProjects(
          sourceUri: testDataUri.resolve('native_add_add_source/'),
          targetUri: packageUri,
        );

        final hookFileLastModified2 = await hookFile.lastModified();
        printOnFailure([
          'hookFile lastModified',
          hookFileLastModified,
          hookFileLastModified2,
        ].toString());
        expect(hookFileLastModified2, isNot(hookFileLastModified));

        {
          final result = await build(packageUri, logger, dartExecutable);
          {
            final compiledHook = logMessages
                .where((m) => m.contains('dart compile kernel'))
                .isNotEmpty;
            expect(compiledHook, isTrue);
          }
          final assetFileLastModified2 = await assetFile.lastModified();

          printOnFailure([
            'assetFile lastModified',
            assetFileLastModified,
            assetFileLastModified2,
          ].toString());
          expect(assetFileLastModified2, isNot(assetFileLastModified));
          final fileSize2 = (await assetFile.readAsBytes()).length;
          printOnFailure(
            ['assetFile fileSize', fileSize, fileSize2].toString(),
          );
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
