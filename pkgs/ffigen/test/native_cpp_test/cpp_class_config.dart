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
      dart: DartOutput(path: testDir.resolve('cpp_class_test_bindings.dart')),
      style: const NativeExternalBindings(assetId: 'package:ffigen/cpp_test'),
    ),
    input: Input(
      entryPoints: [
        testDir.resolve('cpp_class_test.h'),
        testDir.resolve('finalizer_test_subject.h'),
      ],
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
        cppClass: (node) {
          const include = {'Animal', 'FinalizerTestSubject'};
          node.isIncluded = include.contains(node.originalName);
        },
      ),
    ],
  );
}
