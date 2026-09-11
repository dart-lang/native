// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/native_test/');
  final dartPath = outputDir != null
      ? outputDir.resolve('_expected_native_test_bindings.dart')
      : configDir.resolve('_expected_native_test_bindings.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const NativeExternalBindings(
        assetId: 'package:ffigen/native_test',
      ),
    ),
    input: Input(
      entryPoints: [configDir.resolve('native_test.c')],
      include: (uri) => uri.path.endsWith('native_test.c'),
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
        enumClass: (node) {
          node.isIncluded = true;
          if (node.originalName == 'Enum2') {
            node.style = EnumStyle.intConstants;
          }
          node.silenceWarning = true;
        },
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
