// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:file_testing/file_testing.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:hooks_runner/src/build_runner/build_runner.dart';
import 'package:test/test.dart';

import '../build_runner/helpers.dart';
import '../helpers.dart';

void main() async {
  const name = 'user_defines';

  test(
    '$name build',
    () => inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$name/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final logMessages = <String>[];
      final pubspecUri = packageUri.resolve('pubspec.yaml');
      final result =
          (await build(
            packageUri,
            logger,
            dartExecutable,
            capturedLogs: logMessages,
            buildAssetTypes: [BuildAssetType.data],
            userDefines: UserDefines(workspacePubspec: pubspecUri),
          ))!;

      final dataAssets =
          result.encodedAssets.map((e) => e.asDataAsset).toList();
      expect(dataAssets.length, 2);
      for (final dataAsset in dataAssets) {
        expect(File.fromUri(dataAsset.file), exists);
      }

      // The native assets build runner must be reinvoked if the pubspec
      // changes, as the pubspec could contain user-defines.
      expect(result.dependencies, contains(pubspecUri));
    }),
  );
}
