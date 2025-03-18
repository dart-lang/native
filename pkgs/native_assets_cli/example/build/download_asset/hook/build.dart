// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:download_asset/src/hook_helpers/c_build.dart';
import 'package:download_asset/src/hook_helpers/download.dart';
import 'package:download_asset/src/hook_helpers/hashes.dart';
import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  // TODO(https://github.com/dart-lang/native/issues/39): Use user-defines to
  // control this instead.
  const localBuild = false;

  await build(args, (input, output) async {
    // ignore: dead_code
    if (localBuild) {
      await runBuild(input, output);
    } else {
      final targetOS = input.config.code.targetOS;
      final targetArchitecture = input.config.code.targetArchitecture;
      final iOSSdk =
          targetOS == OS.iOS ? input.config.code.iOS.targetSdk : null;
      final outputDirectory = Directory.fromUri(input.outputDirectory);
      final file = await downloadAsset(
        targetOS,
        targetArchitecture,
        iOSSdk,
        outputDirectory,
      );
      final fileHash = await hashAsset(file);
      final expectedHash =
          assetHashes[input.config.code.targetOS.dylibFileName(
            createTargetName(
              targetOS.name,
              targetArchitecture.name,
              iOSSdk?.type,
            ),
          )];
      if (fileHash != expectedHash) {
        throw Exception(
          'File $file was not downloaded correctly. '
          'Found hash $fileHash, expected $expectedHash.',
        );
      }
      output.assets.code.add(
        CodeAsset(
          package: input.packageName,
          name: 'native_add.dart',
          linkMode: DynamicLoadingBundled(),
          os: targetOS,
          architecture: targetArchitecture,
          file: file.uri,
        ),
      );
    }
  });
}
