// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'use_rust';

void main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);
  if (buildConfig.target.abi != Abi.current()) {
    throw Exception('Cross compilation not supported.');
  }

  final cargoResult = await Process.run(
    'cargo',
    ['build'],
    workingDirectory: buildConfig.packageRoot.resolve('rust/').toFilePath(),
  );
  print(cargoResult.stdout);
  print(cargoResult.stderr);
  if (cargoResult.exitCode != 0) {
    exit(cargoResult.exitCode);
  }

  final dylibUri =
      buildConfig.packageRoot.resolve('rust/target/debug/libuse_rust.dylib');
  final dylib = File.fromUri(dylibUri);
  if (!await dylib.exists()) {
    throw Exception('Could not find $dylib.');
  }

  final dylinInOutDirUri = buildConfig.outDir
      .resolve(buildConfig.target.os.dylibFileName(packageName));
  await dylib.copy(dylinInOutDirUri.toFilePath());

  final buildOutput = BuildOutput(
    dependencies: Dependencies([
      buildConfig.packageRoot.resolve('build.dart'),
      buildConfig.packageRoot.resolve('rust/build.rs'),
      buildConfig.packageRoot.resolve('rust/Cargo.toml'),
      buildConfig.packageRoot.resolve('rust/src/lib.rs'),
    ]),
    assets: [
      Asset(
        id: 'package:$packageName/src/${packageName}_bindings_generated.dart',
        linkMode: LinkMode.dynamic,
        target: buildConfig.target,
        path: AssetAbsolutePath(dylinInOutDirUri),
      )
    ],
  );
  await buildOutput.writeToFile(outDir: buildConfig.outDir);
}
