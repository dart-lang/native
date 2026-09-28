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
        path: testDir.resolve('cpp_namespace_enum_test_bindings.dart'),
      ),
    ),
    input: Input(
      entryPoints: [testDir.resolve('cpp_namespace_enum_test.h')],
      compilerOptions: [
        '-x',
        'c++',
        '-std=c++17',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    visitors: [
      Visitor(
        enumClass: (node) => node.isIncluded = {
          'GlobalBox::State',
          'GlobalPalette::Shade',
          'outer::Color',
          'outer::inner::Color',
          'outer::Palette::Tone',
          'other::Color',
        }.contains(node.originalName),
      ),
    ],
  );
}
