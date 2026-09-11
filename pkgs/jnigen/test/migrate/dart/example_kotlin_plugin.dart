// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('example/kotlin_plugin/');
  return JniGenerator(
    input: Input(
      classes: ['Example'],
      backend: SummarizerBackend.asm,
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('example/'),
      ),
    ),
    output: Output(
      dart: DartOutput(
        path:
            outputDir?.resolve('generated.dart') ??
            packageRoot.resolve('lib/kotlin_bindings.dart'),
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
