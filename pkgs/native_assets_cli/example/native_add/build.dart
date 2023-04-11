// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:c_compiler/c_compiler.dart';
import 'package:cli_config/cli_config.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'native_add';
const assetName =
    'package:$packageName/src/${packageName}_bindings_generated.dart';
const sourcePaths = [
  'src/$packageName.c',
];

void main(List<String> args) async {
  final logger = Logger('');
  final config = await Config.fromArgs(args: args);
  final nativeAssetsConfig = BuildConfig.fromConfig(config);
  final outDir = nativeAssetsConfig.outDir;
  final packageRoot = nativeAssetsConfig.packageRoot;
  await Directory.fromUri(outDir).create(recursive: true);
  final packaging = nativeAssetsConfig.packaging.preferredPackaging.first;
  final libUri = outDir.resolve(
      nativeAssetsConfig.target.os.libraryFileName(packageName, packaging));
  final sources = [for (final path in sourcePaths) packageRoot.resolve(path)];

  final task = RunCBuilder(
    config: config,
    logger: logger,
    sources: sources,
    dynamicLibrary: packaging == Packaging.dynamic ? libUri : null,
    staticLibrary: packaging == Packaging.static ? libUri : null,
  );
  await task.run();

  final buildOutput = BuildOutput(
    timestamp: DateTime.now(),
    assets: [
      Asset(
        name: assetName,
        packaging: packaging,
        target: nativeAssetsConfig.target,
        path: AssetAbsolutePath(libUri),
      )
    ],
    dependencies: Dependencies([
      ...sources,
      packageRoot.resolve('build.dart'),
    ]),
  );
  await buildOutput.writeToFile(outDir: outDir);
}
