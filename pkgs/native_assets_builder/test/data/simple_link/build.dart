// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'simple_link';

void main(List<String> args) async {
  final buildConfig = await BuildConfig.fromArgs(args);

  final buildOutput = BuildOutput(
      assets: List.generate(
    4,
    (index) {
      final filename = 'data_$index.json';
      return Asset( // Change to DataAsset
        id: filename,// The BuildState knows the package name.
        linkMode: LinkMode.dynamic, //remove
        target: buildConfig.target, //remove
        path: AssetAbsolutePath(Uri.file(filename)), // change to URI only
      );
    },
  ));
  await buildOutput.writeToFile(output: buildConfig.output);
}


assetBuild(args, (state) => state.add(name, path));

add(String name)=>Asset(id: package + name)
