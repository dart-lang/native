// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/native_cpp_test/');
  final dartPath = outputDir != null
      ? outputDir.resolve('cpp_class_test_bindings.dart')
      : configDir.resolve('cpp_class_test_bindings.dart');
  final cppPath = outputDir != null
      ? outputDir.resolve('cpp_class_test_bindings.dart.cpp')
      : configDir.resolve('cpp_class_test_bindings.dart.cpp');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      cppFile: cppPath,
      style: const NativeExternalBindings(assetId: 'package:ffigen/cpp_test'),
    ),
    input: Input(
      entryPoints: [configDir.resolve('cpp_class_test.h')],
      compilerOptions: [
        '-x c++',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    cpp: const Cpp(),
    visitors: [
      Visitor(
        cppClass: (node) => node.isIncluded = node.originalName == 'Animal',
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
