// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';

import 'package:jnigen/jnigen.dart';

JniGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Uri.directory('example/in_app_java/');
  return JniGenerator(
    input: Input(
      sourcePath: [packageRoot.resolve('android/app/src/main/java')],
      classes: [
        'com.example.in_app_java',
        'androidx.emoji2.text.EmojiCompat',
        'androidx.emoji2.text.DefaultEmojiCompatConfig',
        'android.os.Build',
        'java.util.HashMap',
      ],
      androidSdk: AndroidSdk(addGradleDeps: true, androidExample: packageRoot),
    ),
    output: Output(
      dart: DartOutput(
        path:
            outputDir?.resolve('generated.dart') ??
            packageRoot.resolve('lib/android_utils.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    imports: const SymbolImports(hide: ['java.util.HashMap']),
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
