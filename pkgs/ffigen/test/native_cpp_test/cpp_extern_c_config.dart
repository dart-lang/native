// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);
  final testDir = packageRoot.resolve('test/native_cpp_test/');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: testDir.resolve('cpp_extern_c_test_bindings.dart'),
      ),
    ),
    input: Input(
      entryPoints: [testDir.resolve('cpp_extern_c_test.h')],
      compilerOptions: [
        '-x',
        'c++',
        '-std=c++17',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = {
          'add',
          'deep',
          'reset',
          'outside',
        }.contains(node.originalName),
        struct: (node) => node.isIncluded = node.originalName == 'Pair',
        union: (node) => node.isIncluded = node.originalName == 'Number',
        enumClass: (node) => node.isIncluded = node.originalName == 'Fruit',
        global: (node) => node.isIncluded = node.originalName == 'counter',
      ),
    ],
  );
}
