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
      dart: DartOutput(path: testDir.resolve('cpp_pod_test_bindings.dart')),
      style: const NativeExternalBindings(assetId: 'package:ffigen/cpp_test'),
    ),
    input: Input(
      entryPoints: [testDir.resolve('cpp_pod_test.h')],
      compilerOptions: [
        '-x',
        'c++',
        '-std=c++17',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    cpp: const Cpp(),
    visitors: [
      Visitor(
        // Struct vs C++ class is decided by POD-ness, not by the
        // `class`/`struct` keyword: the POD records (one of them declared
        // with `class`) must arrive as struct nodes, and the non-POD
        // `struct` as a C++ class node.
        struct: (node) {
          const include = {'PodPoint', 'PodPair'};
          node.isIncluded = include.contains(node.originalName);
        },
        cppClass: (node) {
          node.isIncluded = node.originalName == 'NonPodCounter';
        },
      ),
    ],
  );
}
