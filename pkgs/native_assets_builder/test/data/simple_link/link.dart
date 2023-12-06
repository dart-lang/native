// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  print('RUN LINKING');
  final linkInput = await LinkInput.fromArgs(args);

  final shakenAssets = MyResourceShaker().shake(
    linkInput.buildOutput.assets,
    linkInput.resourceIdentifiers,
  );

  final linkOutput = BuildOutput(assets: shakenAssets);
  await linkOutput.writeToFile(
    outDir: linkInput.buildConfig.outDir,
    step: const LinkStep(),
  );
}

class MyResourceShaker {
  List<Asset> shake(
    List<Asset> assets,
    ResourceIdentifiers? resourceIdentifiers,
  ) =>
      assets.skip(2).toList();
}
