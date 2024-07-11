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

/// Compares 2 [Config] objects using [expect] to give useful errors when
/// two fields are not equal.
void expectConfigsAreEqual(Config a, Config b) {
  expect(a.classes, equals(b.classes), reason: 'classes');
  expect(a.outputConfig.dartConfig.path, equals(b.outputConfig.dartConfig.path),
      reason: 'dartRoot');
  expect(a.outputConfig.symbolsConfig?.path,
      equals(b.outputConfig.symbolsConfig?.path),
      reason: 'symbolsRoot');
  expect(a.sourcePath, equals(b.sourcePath), reason: 'sourcePath');
  expect(a.experiments, equals(b.experiments), reason: 'experiments');
  expect(a.classPath, equals(b.classPath), reason: 'classPath');
  expect(a.preamble, equals(b.preamble), reason: 'preamble');
  final am = a.mavenDownloads;
  final bm = b.mavenDownloads;
  if (am != null) {
    expect(bm, isNotNull);
    expect(am.sourceDeps, bm!.sourceDeps, reason: 'mavenDownloads.sourceDeps');
    expect(path.equals(am.sourceDir, bm.sourceDir), isTrue,
        reason: 'mavenDownloads.sourceDir');
    expect(am.jarOnlyDeps, bm.jarOnlyDeps,
        reason: 'mavenDownloads.jarOnlyDeps');
    expect(path.equals(am.jarDir, bm.jarDir), isTrue,
        reason: 'mavenDownloads.jarDir');
  } else {
    expect(bm, isNull, reason: 'mavenDownloads');
  }
  final aa = a.androidSdkConfig;
  final ba = b.androidSdkConfig;
  if (aa != null) {
    expect(ba, isNotNull, reason: 'androidSdkConfig');
    expect(aa.versions, ba!.versions, reason: 'androidSdkConfig.versions');
    expect(aa.sdkRoot, ba.sdkRoot, reason: 'androidSdkConfig.sdkRoot');
  } else {
    expect(ba, isNull, reason: 'androidSdkConfig');
  }
  final aso = a.summarizerOptions;
  final bso = b.summarizerOptions;
  if (aso != null) {
    expect(bso, isNotNull, reason: 'summarizerOptions');
    expect(aso.extraArgs, bso!.extraArgs,
        reason: 'summarizerOptions.extraArgs');
    expect(aso.workingDirectory, bso.workingDirectory,
        reason: 'summarizerOptions.workingDirectory');
    expect(aso.backend, bso.backend, reason: 'summarizerOptions.backend');
  } else {
    expect(bso, isNull, reason: 'summarizerOptions');
  }
}

final jnigenYaml = join(jacksonCoreTests, 'jnigen.yaml');

Config parseYamlConfig({List<String> overrides = const []}) =>
    Config.parseArgs(['--config', jnigenYaml, ...overrides]);

void testForErrorChecking<T extends Exception>(
    {required String name,
    required List<String> overrides,
    dynamic Function(Config)? function}) {
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
  final config = Config.parseArgs([
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
