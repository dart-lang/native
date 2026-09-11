// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/native_objc_test/');
  final dartPath = outputDir != null
      ? outputDir.resolve('enum_test_bindings.dart')
      : configDir.resolve('enum_test_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('enum_test_bindings.dart.m')
      : configDir.resolve('enum_test_bindings.dart.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(
      entryPoints: [
        configDir.resolve('enum_test.m'),
        configDir.resolve('enum_test.m'),
        configDir.resolve('enum_test.m'),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        enumClass: (node) => node.isIncluded = {
          'Fruit',
          'CoffeeOptions',
        }.contains(node.originalName),
        unnamedEnumConstant: (node) =>
            node.isIncluded = node.originalName == 'UnnamedEnumValue',
        macroConstant: (node) =>
            node.isIncluded = node.originalName == 'SOME_MACRO',
        objCInterface: (node) =>
            node.isIncluded = node.originalName == 'EnumTestInterface',
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
