// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_statements, deprecated_member_use

import 'package:native_assets_cli/code_assets.dart';
import 'package:native_assets_cli/data_assets.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    // a. shared
    input.packageName;
    input.packageRoot;
    input.outputDirectory;
    input.outputDirectoryShared;
    // b. hook-specific
    input.metadata; // build only
    // c. target config
    // c.1. per hook
    input.config.linkingEnabled; // build only
    // c.2. per asset
    input.config.buildAssetTypes;
    input.config.code.linkModePreference;
    input.config.code.targetArchitecture;
    input.config.code.targetOS;
    input.config.code.android.targetNdkApi;
    input.config.code.iOS.targetSdk;
    input.config.code.iOS.targetVersion;
    input.config.code.macOS.targetVersion;
    input.config.code.cCompiler?.archiver;
    input.config.code.cCompiler?.compiler;
    input.config.code.cCompiler?.linker;

    output.assets.code.add(
      CodeAsset(
        package: 'package',
        name: 'name',
        linkMode: DynamicLoadingBundled(),
        os: input.config.code.targetOS,
        architecture: input.config.code.targetArchitecture,
        file: input.outputDirectory.resolve('foo'),
      ),
    );
    output.assets.data.add(
      DataAsset(
        file: input.outputDirectory.resolve('foo'),
        name: 'name',
        package: 'package',
      ),
      linkInPackage: 'foo',
    );
    output.addDependency(input.packageRoot.resolve('x.txt'));
  });
}
