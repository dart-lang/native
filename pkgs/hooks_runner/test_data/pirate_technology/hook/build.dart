// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final dataFile = input.packageRoot.resolve('data/tech.json');
    final techFile = input.outputDirectoryShared.resolve('tech.json');
    await File.fromUri(dataFile).copy(techFile.toFilePath());

    output.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: 'technologies',
        file: techFile,
      ),
      routing: input.config.linkingEnabled
          ? const ToLinkHook('pirate_technology')
          : const ToAppBundle(),
    );
  });
}
