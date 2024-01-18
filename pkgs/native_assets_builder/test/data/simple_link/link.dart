// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final linkConfig = await LinkConfig.fromArgs(args);

  final shakenAssets = MyResourceShaker().shake(
    linkConfig.assets,
    linkConfig.resourceIdentifiers,
  );

  final linkOutput = BuildOutput(
      assets: shakenAssets.map((e) {
    final path = e.path as AssetAbsolutePath;
    final filePath = path.uri.toFilePath();
    final uri = linkConfig.buildConfig.outDir.resolve(p.basename(filePath));
    File(filePath).copySync(uri.toFilePath());
    return Asset(
      id: e.id,
      linkMode: e.linkMode,
      target: e.target,
      path: AssetAbsolutePath(uri),
    );
  }).toList());

  await linkOutput.writeToFile(output: linkConfig.output);
}

class MyResourceShaker {
  List<Asset> shake(
    List<Asset> assets,
    ResourceIdentifiers? resourceIdentifiers,
  ) =>
      assets.skip(2).toList();
}
