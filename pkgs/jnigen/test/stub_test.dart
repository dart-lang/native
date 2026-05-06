// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/util/dart_executable.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

Config _getConfig({required bool generateStubs, required Uri outputPath}) {
  final testRoot = join('test', 'stub_test');
  final javaPath = join(testRoot, 'java');
  return Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    classes: ['com.example.A', 'com.example.C'],
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: outputPath,
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
    final tempDir = getTempDir('stub_test_');
    tearDownAll(() {
      tempDir.deleteSync(recursive: true);
    });

    Future<void> generateAndVerify(bool stubsEnabled) async {
      final suffix = stubsEnabled ? 'enabled' : 'disabled';
      final output = tempDir.uri.resolve('bindings_$suffix.dart');
      final config =
          _getConfig(generateStubs: stubsEnabled, outputPath: output);
      await generateJniBindings(config);

      final analyzeResult =
          Process.runSync(dartExecutable, ['analyze', output.toFilePath()]);
      if (analyzeResult.exitCode != 0) {
        stderr.write(analyzeResult.stdout);
        fail(
            'Analyzer exited with non-zero status (${analyzeResult.exitCode})');
      }

      final content = File.fromUri(output).readAsStringSync();
      if (stubsEnabled) {
        // When stubs are enabled, we should see specific stub types.
        expect(content, contains('B? get b'));
        expect(content, contains('void takeB('));
        expect(content, contains('B? b,'));
        expect(content, contains('void takeD('));
        expect(content, contains('D? d,'));

        // Stub classes should exist with warnings.
        expect(content, contains('extension type B'));
        expect(content, contains('WARNING: B is a stub'));
        expect(content, contains('extension type D'));
        expect(content, contains('WARNING: D is a stub'));

        // Transitive dependencies (E) shouldn't be generated if not referenced.
        expect(content, isNot(contains('extension type E')));
      } else {
        // When stubs are disabled, we should see JObject for excluded types.
        expect(content, contains(r'jni$_.JObject? get b'));
        expect(content, contains(r'void takeB('));
        expect(content, contains(r'jni$_.JObject? b,'));
        expect(content, contains(r'void takeD('));
        expect(content, contains(r'jni$_.JObject? d,'));

        // Stub classes should NOT exist.
        expect(content, isNot(contains('extension type B')));
        expect(content, isNot(contains('extension type D')));
      }
    }

    test('Generate bindings with stubs disabled', () async {
      await generateAndVerify(false);
    });

    test('Generate bindings with stubs enabled', () async {
      await generateAndVerify(true);
    });
  });
}
