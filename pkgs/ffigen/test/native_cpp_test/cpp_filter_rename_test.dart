// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'util.dart';

void main() {
  group('cpp_filter_rename_test', () {
    final testDir = Directory(
      path.join(packagePathForTests, 'test', 'native_cpp_test'),
    );

    final defaultCppCompilerOptions = [
      '-x',
      'c++',
      '-std=c++17',
      if (Platform.isMacOS) ...['-isysroot', macSdkPath],
    ];

    final config = FfiGenerator(
      output: Output(
        dart: DartOutput(
          path: Uri.file('cpp_filter_rename_test_bindings.dart'),
        ),
        style: const NativeExternalBindings(assetId: 'package:ffigen/cpp_test'),
      ),
      input: Input(
        entryPoints: [
          Uri.file(path.join(testDir.path, 'cpp_filter_rename_test.h')),
        ],
        compilerOptions: defaultCppCompilerOptions,
      ),
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

    test('verifyBindings for cpp_filter_rename_test.dart', () {
      verifyBindings(config);
    });
  });
}
