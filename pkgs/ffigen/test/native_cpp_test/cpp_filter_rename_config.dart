// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig(Uri packageRoot) {
  final testDir = packageRoot.resolve('test/native_cpp_test/');

  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: Uri.file('cpp_filter_rename_test_bindings.dart')),
      style: const NativeExternalBindings(assetId: 'package:ffigen/cpp_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('cpp_filter_rename_test.h')]),
    cpp: const Cpp(),
    visitors: [
      Visitor(
        cppClass: (node) {
          node.isIncluded = {
            'MyClass',
            'OtherClass',
          }.contains(node.originalName);
          if (node.originalName == 'MyClass') {
            node.name = 'MyWidget';
          }
        },
        cppMethod: (node) {
          if (node.parent.originalName == 'MyClass' &&
              node.originalName != 'myMethod') {
            node.isIncluded = false;
          }
          if (node.originalName == 'myMethod') {
            node.name = 'greet';
          }
        },
      ),
    ],
  );
}
