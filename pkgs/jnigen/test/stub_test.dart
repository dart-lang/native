// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

Config _getConfig({required bool generateStubs}) {
  final testRoot = join('test', 'stub_test');
  final javaPath = join(testRoot, 'java');
  return Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    classes: ['com.example.A', 'com.example.C'],
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: Uri.file(join(testRoot, 'bindings.dart')),
        structure: OutputStructure.singleFile,
      ),
    ),
    generateStubs: generateStubs,
  );
}

void main() async {
  if (!Platform.isAndroid && !Platform.isLinux && !Platform.isMacOS) {
    return;
  }

  await checkLocallyBuiltDependencies();

  group('Stub generation', () {
    test('Generate bindings with stubs disabled', () async {
      await generateAndAnalyzeBindings(_getConfig(generateStubs: false));
    });

    test('Generate bindings with stubs enabled', () async {
      await generateAndAnalyzeBindings(_getConfig(generateStubs: true));
    });

    test('Stub runtime tests', () async {
      final result = await Process.run(
        Platform.executable,
        ['test', 'test/stub_test/runtime_standalone.dart'],
      );
      if (result.exitCode != 0) {
        stderr.writeln(result.stdout);
        stderr.writeln(result.stderr);
      }
      expect(result.exitCode, equals(0));
    });
  });
}
