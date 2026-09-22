// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:prebuilt_assets_example/src/hook_helpers/c_build.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final localBuild = input.userDefines['local_build'] as bool? ?? false;
    final targetOS = input.config.code.targetOS;
    final targetArchitecture = input.config.code.targetArchitecture;
    final iOSSdk = targetOS == OS.iOS ? input.config.code.iOS.targetSdk : null;
    final fileName = targetFileName(targetOS, targetArchitecture, iOSSdk);
    final assetUri = input.packageRoot.resolve('prebuilt/$fileName');
    final assetFile = File.fromUri(assetUri);

    if (localBuild || !assetFile.existsSync()) {
      await runBuild(input, output);
    } else {
      output.dependencies.add(assetUri);
      output.assets.code.add(
        CodeAsset(
          package: input.packageName,
          name: 'native_add.dart',
          linkMode: DynamicLoadingBundled(),
          file: assetUri,
        ),
      );
    }
  });
}
