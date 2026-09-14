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
        path: testDir.resolve('block_inherit_test_bindings.dart'),
      ),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('block_inherit_test.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          const include = {
            'Mammal',
            'Platypus',
            'BlockInheritTestBase',
            'BlockInheritTestChild',
          };
          node.isIncluded = include.contains(node.originalName);
        },
        typealias: (node) {
          const include = {
            'ReturnMammal',
            'ReturnPlatypus',
            'AcceptMammal',
            'AcceptPlatypus',
          };
          node.isIncluded = include.contains(node.name) ? .always : .never;
        },
      ),
    ],
  );
}
