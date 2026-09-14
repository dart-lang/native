// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../example/ffinative/');
  final dartPath = outputDir != null
      ? outputDir.resolve('generated_bindings.dart')
      : packageRoot.resolve('lib/generated_bindings.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const NativeExternalBindings(
        assetId: 'package:ffinative_example/generated_bindings.dart',
      ),
      preamble: '''
// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
    ),
    input: Input(entryPoints: [packageRoot.resolve('headers/example.h')]),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded = true;
          if (node.originalName == 'sum') {
            node.exposeSymbolAddress = true;
          }
        },
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
          node.isIncluded = true;
          if (node.originalName == 'library_version') {
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
