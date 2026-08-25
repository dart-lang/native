// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/config/config.dart';
import 'package:path/path.dart' as path show equals;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'jackson_core_test/generate.dart';
import 'test_util/test_util.dart';

const packageTests = 'test';
final jacksonCoreTests = absolute(packageTests, 'jackson_core_test');
final thirdParty = absolute(jacksonCoreTests, 'third_party');
final testLib = absolute(thirdParty, 'test_', 'bindings');

/// Compares 2 [JniGenerator] objects using [expect] to give useful errors when
/// two fields are not equal.
void expectConfigsAreEqual(JniGenerator a, JniGenerator b) {
  expect(a.input.classes, equals(b.input.classes), reason: 'classes');
  expect(a.output.dart.path, equals(b.output.dart.path), reason: 'dartRoot');
  expect(a.output.symbols?.path, equals(b.output.symbols?.path),
      reason: 'symbolsRoot');
  expect(a.input.sourcePath, equals(b.input.sourcePath), reason: 'sourcePath');
  expect(a.input.classPath, equals(b.input.classPath), reason: 'classPath');
  expect(a.output.preamble, equals(b.output.preamble), reason: 'preamble');
  final am = a.input.mavenDownloads;
  final bm = b.input.mavenDownloads;
  if (am != null) {
    expect(bm, isNotNull);
    expect(am.sourceDeps, bm!.sourceDeps, reason: 'mavenDownloads.sourceDeps');
    expect(path.equals(am.sourceDir.toFilePath(), bm.sourceDir.toFilePath()),
        isTrue,
        reason: 'mavenDownloads.sourceDir');
    expect(am.jarOnlyDeps, bm.jarOnlyDeps,
        reason: 'mavenDownloads.jarOnlyDeps');
    expect(path.equals(am.jarDir.toFilePath(), bm.jarDir.toFilePath()), isTrue,
        reason: 'mavenDownloads.jarDir');
  } else {
    expect(bm, isNull, reason: 'mavenDownloads');
  }
  final aa = a.input.androidSdk;
  final ba = b.input.androidSdk;
  if (aa != null) {
    expect(ba, isNotNull);
    expect(aa.versions, ba!.versions, reason: 'androidSdk.versions');
    expect(aa.sdkRoot, ba.sdkRoot, reason: 'androidSdk.sdkRoot');
  } else {
    expect(ba, isNull, reason: 'androidSdk');
  }
  expect(a.input.extraArgs, b.input.extraArgs, reason: 'extraArgs');
  expect(a.input.workingDirectory, b.input.workingDirectory,
      reason: 'workingDirectory');
  expect(a.input.backend, b.input.backend, reason: 'backend');
  expect(a.input.summarizerCommand, equals(b.input.summarizerCommand),
      reason: 'summarizerCommand');
  expect(a.imports.symbolFiles, b.imports.symbolFiles,
      reason: 'imports.symbolFiles');
  expect(a.imports.hide, b.imports.hide, reason: 'imports.hide');
}

final jnigenYaml = join(jacksonCoreTests, 'jnigen.yaml');

JniGenerator parseYamlConfig({List<String> overrides = const []}) =>
    JniGenerator.parseArgs(['--config', jnigenYaml, ...overrides]);

void testForErrorChecking<T extends Exception>(
    {required String name,
    required List<String> overrides,
    dynamic Function(JniGenerator)? function}) {
  test(name, () {
    expect(
      () {
        final config = parseYamlConfig(overrides: overrides);
        if (function != null) {
          function(config);
        }
      },
      throwsA(isA<T>()),
    );
  });
}

void main() async {
  await checkLocallyBuiltDependencies();
  final config = JniGenerator.parseArgs([
    '--config',
    jnigenYaml,
    '-Doutput.dart.path=$testLib${Platform.pathSeparator}',
  ]);

  test('compare configuration values', () {
    expectConfigsAreEqual(
      config,
      getConfig(
        root: join(thirdParty, 'test_'),
      ),
    );
  });

  group('Test for config error checking', () {
    testForErrorChecking<ConfigException>(
      name: 'Invalid output structure',
      overrides: ['-Doutput.dart.structure=singl_file'],
    );
    testForErrorChecking<ConfigException>(
      name: 'Dart path not ending with /',
      overrides: ['-Doutput.dart.path=lib'],
    );
    testForErrorChecking<FormatException>(
      name: 'Invalid log level',
      overrides: ['-Dlog_level=inf'],
    );
    testForErrorChecking<ConfigException>(
      name: 'Nested class specified',
      overrides: ['-Dclasses=com.android.Clock\$Clock'],
    );
  });
}
