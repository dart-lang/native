// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'simple_link';

void main(List<String> args) async {
  print('RUN BUILDING');
  final buildConfig = await BuildConfig.fromArgs(args);
  final buildOutput = BuildOutput(
      assets: List.generate(
    4,
    (index) {
      final filename = 'data_$index.json';
      return Asset(
        id: 'package:$packageName/$filename',
        linkMode: LinkMode.dynamic,
        target: buildConfig.target,
        path: AssetAbsolutePath(Uri.file(File(filename).absolute.path)),
      );
    },
  ));
  await buildOutput.writeToFile(
    outDir: buildConfig.outDir,
    step: const BuildStep(),
  );
}
