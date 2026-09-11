// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/header_parser_tests/');
  final dartPath = outputDir != null
      ? outputDir.resolve('unused')
      : configDir.resolve('unused');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibrary',
        wrapperDocComment: 'Static Const Test',
      ),
    ),
    input: Input(
      entryPoints: [configDir.resolve('static_const.h')],
      include: (uri) => uri.path.endsWith('static_const.h'),
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
