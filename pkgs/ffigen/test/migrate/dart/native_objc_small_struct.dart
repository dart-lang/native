// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/native_objc_test/');
  final dartPath = outputDir != null
      ? outputDir.resolve('small_struct_test_bindings.dart')
      : configDir.resolve('small_struct_test_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('small_struct_test_bindings.m')
      : configDir.resolve('small_struct_test_bindings.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [configDir.resolve('small_struct_test.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        typealias: (node) => node.isIncluded =
            ({
              'Struct8',
              'Struct16',
              'Struct24',
              'Struct32',
              'Struct8Block',
              'Struct16Block',
              'Struct24Block',
              'Struct32Block',
              'Union8',
              'Union16',
              'Union24',
              'Union32',
              'Union8Block',
              'Union16Block',
              'Union24Block',
              'Union32Block',
            }.contains(node.originalName))
            ? TypealiasInclude.ifUsed
            : TypealiasInclude.never,
        objCInterface: (node) =>
            node.isIncluded = node.originalName == 'SmallStructTester',
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
