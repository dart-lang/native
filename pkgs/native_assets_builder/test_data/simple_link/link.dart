// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final linkConfig = await LinkConfig.fromArguments(args);

  link(args, (config, output) async {
    final shakenAssets = MyResourceShaker().shake(
      linkConfig.assets,
      linkConfig.resourceIdentifiers,
    );

    final linkOutput = shakenAssets.map((e) {
      final filePath = e.file!.toFilePath();
      final uri = linkConfig.outDirectory.resolve(p.basename(filePath));
      File(filePath).copySync(uri.toFilePath());
      return DataAsset.fromId(id: e.id, file: uri);
    }).toList();

    output.addAssets(linkOutput);
  });
}

class MyResourceShaker {
  List<Asset> shake(
    List<Asset> assets,
    ResourceIdentifiers? resourceIdentifiers,
  ) =>
      assets.skip(2).toList();
}
