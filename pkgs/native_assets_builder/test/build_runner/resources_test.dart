// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test(
    'simple_link linking',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('simple_link/');

        final resourcesUri = tempUri.resolve('treeshaking_info.json');
        await File.fromUri(resourcesUri).create();

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(
          workingDirectory: packageUri,
          logger: logger,
        );

        final buildResult = (await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
          supportedAssetTypes: [DataAsset.type],
          buildValidator: validateDataAssetBuildOutput,
          applicationAssetValidator: (_) async => [],
        ))!;

        Iterable<String> buildFiles() => Directory.fromUri(
                packageUri.resolve('.dart_tool/native_assets_builder/'))
            .listSync(recursive: true)
            .map((file) => file.path);

        expect(buildFiles(), isNot(anyElement(endsWith('resources.json'))));

        await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          resourceIdentifiers: resourcesUri,
          supportedAssetTypes: [DataAsset.type],
          linkValidator: validateDataAssetLinkOutput,
          applicationAssetValidator: (_) async => [],
        );
        expect(buildFiles(), anyElement(endsWith('resources.json')));
      });
    },
  );
}
