// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../example/shared_bindings/');
  final configDir = packageRoot.resolve('ffigen_configs/');
  final dartPath = outputDir != null
      ? outputDir.resolve('base_gen.dart')
      : configDir.resolve('../lib/generated/base_gen.dart');
  final symbolFilePath = outputDir != null
      ? outputDir.resolve('base_symbols.yaml')
      : packageRoot.resolve('lib/generated/base_symbols.yaml');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      symbolFile: SymbolFile(
        Uri.parse('package:shared_bindings/generated/base_gen.dart'),
        symbolFilePath,
      ),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibraryBase',
        wrapperDocComment: 'Bindings to `headers/base.h`.',
      ),
    ),
    input: Input(entryPoints: [configDir.resolve('../headers/base.h')]),
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
