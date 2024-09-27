// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart' as api;
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test(
    'set last modified date of assets to build output timestamp',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('asset_build_time/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(
          workingDirectory: packageUri,
          logger: logger,
        );

        final result = await build(
          packageUri,
          logger,
          dartExecutable,
          supportedAssetTypes: [api.NativeCodeAsset.type, api.DataAsset.type],
        );

        expect(result.assets, hasLength(2));

        final buildTimeLibraryUri =
            result.assets.whereType<NativeCodeAssetImpl>().single.file!;
        final buildDirectoryUri = buildTimeLibraryUri.resolve('./');

        final buildOutputUri = buildDirectoryUri.resolve('build_output.json');
        final buildOutput = HookOutputImpl.fromJsonString(
            await File.fromUri(buildOutputUri).readAsString());

        expect(
          File.fromUri(buildTimeLibraryUri).lastModifiedSync(),
          buildOutput.timestamp,
        );

        final buildTimeDataAssetUri =
            result.assets.whereType<DataAssetImpl>().single.file;
        expect(
          File.fromUri(buildTimeDataAssetUri).lastModifiedSync(),
          buildOutput.timestamp,
        );
      });
    },
  );
}
