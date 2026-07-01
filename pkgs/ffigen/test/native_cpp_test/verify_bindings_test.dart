// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/config_provider/config.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'util.dart';

void main() {
  group('verify_bindings_test', () {
    final testDir = Directory(
      path.join(packagePathForTests, 'test', 'native_cpp_test'),
    );

    const excludedTests = {'verify_bindings_test.dart'};

    final testFiles =
        testDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_test.dart'))
            .map((f) => path.basename(f.path))
            .where((f) => !excludedTests.contains(f))
            .toList()
          ..sort();

    final configs = <String, FfiGenerator>{
      'cpp_class': FfiGenerator(
        output: Output(
          dartFile: Uri.file('cpp_class_test_bindings.dart'),
          style: const NativeExternalBindings(
            assetId: 'package:ffigen/cpp_test',
          ),
        ),
        headers: Headers(
          entryPoints: [
            Uri.file(path.join(testDir.path, 'cpp_class_test.h')),
            Uri.file(path.join(testDir.path, 'finalizer_test_subject.h')),
          ],
          compilerOptions: ['-x', 'c++'],
        ),
        cpp: Cpp(
          classes: CppClasses.includeSet({'Animal', 'FinalizerTestSubject'}),
        ),
      ),
    };

    for (final testFile in testFiles) {
      final configName = testFile.replaceFirst('_test.dart', '');
      test('verifyBindings for $testFile', () {
        final config = configs[configName];
        if (config == null) {
          fail('No FfiGenerator config registered for $testFile in `configs`.');
        }
        verifyBindings(config);
      });
    }
  });
}
