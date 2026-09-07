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
        path: testDir.resolve('runtime_version_test_bindings.dart'),
      ),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
      preamble: '// ignore_for_file: unused_element\n',
    ),
    input: Input(entryPoints: [testDir.resolve('runtime_version_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          const include = {'FutureAPIInterface', 'FutureAPIMethods'};
          node.isIncluded = include.contains(node.originalName);
        },
        objCCategory: (node) {
          node.isIncluded = node.originalName == 'FutureAPICategoryMethods';
        },
      ),
    ],
  );
}
