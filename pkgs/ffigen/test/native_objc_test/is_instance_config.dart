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
      dart: DartOutput(path: testDir.resolve('is_instance_test_bindings.dart')),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('is_instance_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          const include = {'IsInstanceChildClass', 'IsInstanceUnrelatedClass'};
          node.isIncluded = include.contains(node.originalName);
        },
      ),
    ],
  );
}
