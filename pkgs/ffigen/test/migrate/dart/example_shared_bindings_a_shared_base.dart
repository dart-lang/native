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
      ? outputDir.resolve('a_shared_b_gen.dart')
      : configDir.resolve('../lib/generated/a_shared_b_gen.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const DynamicLibraryBindings(
        wrapperName: 'NativeLibraryASharedB',
        wrapperDocComment:
            'Bindings to `headers/a.h` with shared definitions from `headers/base.h`.',
      ),
    ),
    input: Input(entryPoints: [configDir.resolve('../headers/a.h')]),
    importType: importFromSymbolFile(
      packageRoot.resolve('lib/generated/base_symbols.yaml'),
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
