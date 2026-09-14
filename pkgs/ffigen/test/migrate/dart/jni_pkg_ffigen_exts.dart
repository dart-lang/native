// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../../jni/');
  final dartPath = outputDir != null
      ? outputDir.resolve('unused.dart')
      : packageRoot.resolve('unused.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const DynamicLibraryBindings(
        wrapperName: 'JniExtensions',
        wrapperDocComment: '''
This config is for use by the script that generates extension methods in C.
This config only scans jni.h and does not do renaming etc..
''',
      ),
    ),
    input: Input(
      entryPoints: [packageRoot.resolve('third_party/jni.h')],
      include: (uri) => Glob('/**/third_party/jni.h').matches(uri.path),
      compilerOptions: [
        '-I${packageRoot.resolve('third_party').toFilePath()}',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) {
          node.isIncluded = true;
          node.dependencies = CompoundDependencies.full;
        },
        union: (node) {
          node.isIncluded = true;
          node.dependencies = CompoundDependencies.full;
        },
        enumClass: (node) => node.isIncluded = true,
        global: (node) => node.isIncluded = true,
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = TypealiasInclude.ifUsed,
      ),
    ],
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
      ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
      : null;
  await getConfig(outputDir: outputDir).generate();
}
