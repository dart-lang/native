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
  test('cached build', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final logMessages = <String>[];
        final result = await build(packageUri, logger, dartExecutable,
            capturedLogs: logMessages);
        expect(
          logMessages.join('\n'),
          contains(
            'native_add${Platform.pathSeparator}hook'
            '${Platform.pathSeparator}build.dart',
          ),
        );
        expect(
          result.dependencies,
          [
            packageUri.resolve('hook/build.dart'),
            packageUri.resolve('src/native_add.c'),
          ],
        );
      }

      {
        final logMessages = <String>[];
        final result = await build(packageUri, logger, dartExecutable,
            capturedLogs: logMessages);
        expect(
          logMessages.join('\n'),
          contains('Skipping build for native_add'),
        );
        expect(
          logMessages.join('\n'),
          isNot(contains(
            'native_add${Platform.pathSeparator}hook'
            '${Platform.pathSeparator}build.dart',
          )),
        );
        expect(
          result.dependencies,
          [
            packageUri.resolve('hook/build.dart'),
            packageUri.resolve('src/native_add.c'),
          ],
        );
      }
    });
  });

  test('modify C file', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final result = await build(packageUri, logger, dartExecutable);
        await expectSymbols(
            asset: result.assets.single as NativeCodeAssetImpl,
            symbols: ['add']);
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_add_symbol/'),
        targetUri: packageUri,
      );

      {
        final result = await build(packageUri, logger, dartExecutable);
        await expectSymbols(
          asset: result.assets.single as NativeCodeAssetImpl,
          symbols: ['add', 'subtract'],
        );
      }
    });
  });

  test('add C file, modify hook', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      {
        final result = await build(packageUri, logger, dartExecutable);
        await expectSymbols(
            asset: result.assets.single as NativeCodeAssetImpl,
            symbols: ['add']);
      }

      await copyTestProjects(
          sourceUri: testDataUri.resolve('native_add_add_source/'),
          targetUri: packageUri);

      {
        final result = await build(packageUri, logger, dartExecutable);
        await expectSymbols(
            asset: result.assets.single as NativeCodeAssetImpl,
            symbols: ['add', 'multiply']);
      }
    });
  });
}
