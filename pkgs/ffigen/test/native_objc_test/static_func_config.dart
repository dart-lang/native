// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);
  final testDir = packageRoot.resolve('test/native_objc_test/');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: testDir.resolve('static_func_test_bindings.dart')),
      style: const DynamicLibraryBindings(
        wrapperName: 'StaticFuncTestObjCLibrary',
        wrapperDocComment: 'Test ObjC static functions',
      ),
    ),
    input: Input(entryPoints: [testDir.resolve('static_func_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        func: (node) {
          const include = {
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
          };
          if (include.contains(node.name)) {
            node.isIncluded = true;
          }
        },
        objCInterface: (node) {
          if (node.originalName == 'StaticFuncTestObj') {
            node.isIncluded = true;
          }
        },
      ),
    ],
  );
}
