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
      ? outputDir.resolve('static_func_test_bindings.dart')
      : configDir.resolve('static_func_test_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('static_func_test_bindings.dart.m')
      : configDir.resolve('static_func_test_bindings.dart.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const DynamicLibraryBindings(
        wrapperName: 'StaticFuncTestObjCLibrary',
        wrapperDocComment: 'Test ObjC static functions',
      ),
    ),
    input: Input(entryPoints: [configDir.resolve('static_func_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = {
          'foo',
          'fooPtr',
          'staticFuncOfObject',
          'staticFuncOfNullableObject',
          'staticFuncOfBlock',
          'staticFuncReturnsRetained',
          'staticFuncReturnsRetainedArg',
          'staticFuncConsumesArg',
          'objc_autoreleasePoolPush',
          'objc_autoreleasePoolPop',
        }.contains(node.originalName),
        objCInterface: (node) =>
            node.isIncluded = node.originalName == 'StaticFuncTestObj',
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
