// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_statements

import 'package:native_assets_cli/code_assets.dart';
import 'package:native_assets_cli/data_assets.dart';

void main(List<String> args) async {
  await link(args, (input, output) async {
    // a. shared
    input.packageName;
    input.packageRoot;
    input.outputDirectory;
    input.outputDirectoryShared;
    // b. hook-specific
    input.assets.code; // link only
    input.assets.data; // link only
    input.recordedUsagesFile; // link only
    // c. target config
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

    output.assets.code.addAll(input.assets.code);
    output.assets.data.addAll(input.assets.data);

    output.addDependency(input.packageRoot.resolve('x.txt'));
  });
}
