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
      dart: DartOutput(
        path: testDir.resolve('small_struct_test_bindings.dart'),
      ),
      objectiveCFile: testDir.resolve('small_struct_test_bindings.m'),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('small_struct_test.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          node.isIncluded = node.originalName == 'SmallStructTester';
        },
        typealias: (node) {
          const include = {
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
          };
          node.isIncluded = include.contains(node.name) ? .always : .never;
        },
      ),
    ],
  );
}
