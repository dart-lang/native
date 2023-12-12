// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  print('RUN LINKING');
  final linkConfig = await LinkConfig.fromArgs(args);

  final shakenAssets = MyResourceShaker().shake(
    linkConfig.assets,
    linkConfig.resourceIdentifiers,
  );

  final linkOutput = BuildOutput(assets: shakenAssets);

  await linkOutput.writeToFile(output: linkConfig.output);
}

class MyResourceShaker {
  List<Asset> shake(
    List<Asset> assets,
    ResourceIdentifiers? resourceIdentifiers,
  ) =>
      assets.skip(2).toList();
}
