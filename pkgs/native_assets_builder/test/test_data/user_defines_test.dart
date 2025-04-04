// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:io';

import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

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

      final pubspec =
          loadYamlDocument(
                File.fromUri(
                  packageUri.resolve('pubspec.yaml'),
                ).readAsStringSync(),
              ).contents
              as YamlMap;
      expect(
        NativeAssetsBuildRunner.validateHooksUserDefinesFromPubspec(pubspec),
        isEmpty,
      );
      final userDefines =
          NativeAssetsBuildRunner.readHooksUserDefinesFromPubspec(pubspec);

      final logMessages = <String>[];
      final result =
          (await build(
            packageUri,
            logger,
            dartExecutable,
            capturedLogs: logMessages,
            buildAssetTypes: [BuildAssetType.data],
            userDefines: userDefines,
          ))!;

      expect(result.encodedAssets.length, 1);
    }),
  );
}
