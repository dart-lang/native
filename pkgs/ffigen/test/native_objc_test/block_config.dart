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
      dart: DartOutput(path: testDir.resolve('block_test_bindings.dart')),
      objectiveCFile: testDir.resolve('block_test_bindings.m'),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('block_test.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        func: (node) {
          const include = {
            'objc_autoreleasePoolPop',
            'objc_autoreleasePoolPush',
          };
          if (include.contains(node.name)) {
            node.isIncluded = true;
          }
        },
        objCInterface: (node) {
          const include = {'BlockTester', 'DummyObject', 'NSThread'};
          if (include.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
        typealias: (node) {
          const include = {
            'IntBlock',
            'FloatBlock',
            'DoubleBlock',
            'Vec4Block',
            'SelectorBlock',
            'VoidBlock',
            'ObjectBlock',
            'NullableObjectBlock',
            'BlockBlock',
            'ListenerBlock',
            'ObjectListenerBlock',
            'NullableListenerBlock',
            'StructListenerBlock',
            'NSStringListenerBlock',
            'NoTrampolineListenerBlock',
          };
          if (include.contains(node.name)) {
            node.isIncluded = TypealiasInclude.always;
          }
        },
      ),
    ],
  );
}
