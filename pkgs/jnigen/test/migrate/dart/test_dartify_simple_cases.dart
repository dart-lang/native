// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';

import 'package:jnigen/jnigen.dart';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('test/simple_package_test/');
  return JniGenerator(
    input: Input(sourcePath: [packageRoot.resolve('java')], classes: ['com']),
    output: Output(
      dart: DartOutput(
        path:
            outputDir?.resolve('generated.dart') ??
            packageRoot.resolve('bindings.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.firstOrNull != null
      ? Uri.directory(args.first)
      : (Platform.environment['OUTPUT_DIR'] != null
            ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
            : null);
  await getConfig(outputDir: outputDir).generate();
}
