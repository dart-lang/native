// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final packageName = input.packageName;
    const duplicatedPackageName = 'native_add';
    final cbuilder = CBuilder.library(
      name: duplicatedPackageName,
      assetName: 'src/${packageName}_bindings_generated.dart',
      sources: ['src/$duplicatedPackageName.c'],
    );
    // Temp output to prevent outputting the dylib for bundling.
    final outputBuilder = BuildOutputBuilder();
    await cbuilder.run(
      input: input,
      output: outputBuilder,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.time}: ${record.message}');
        }),
    );
    final tempBuildOutput = outputBuilder.build();
    output.assets.code.add(
      tempBuildOutput.assets.code.single,
      // Send dylib to linking if linking is enabled.
      routing: input.config.linkingEnabled
          ? ToLinkHook(packageName)
          : const ToAppBundle(),
    );
    output.addDependencies(tempBuildOutput.dependencies);
  });
}
