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
        wrapperDocComment: 'Globals Test',
      ),
    ),
    input: Input(
      entryPoints: [configDir.resolve('globals.h')],
      include: (uri) => uri.path.endsWith('globals.h'),
      compilerOptions: [
        '-Wno-nullability-completeness',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
      ignoreSourceErrors: true,
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
        global: (node) {
          node.isIncluded = node.originalName != 'GlobalIgnore';
          if ({
            'myInt',
            'pointerToLongDouble',
            'globalStruct',
          }.contains(node.originalName)) {
            node.exposeSymbolAddress = true;
          }
        },
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
