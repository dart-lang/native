// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/migrate/yaml/');
  final dartPath = outputDir != null
      ? outputDir.resolve('comprehensive_c_native_bindings.dart')
      : configDir.resolve('comprehensive_c_native_bindings.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const NativeExternalBindings(
        assetId: 'package:ffigen/c_native_test',
      ),
      commentType: const CommentType.none(),
    ),
    input: Input(
      entryPoints: [configDir.resolve('comprehensive_c_native.h')],
      compilerOptions: [
        '-I${configDir.resolve('.').toFilePath()}',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded = node.originalName == 'add';
          node.isLeaf = true;
        },
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
