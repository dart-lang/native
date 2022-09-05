// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/config/config.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' hide equals;

import 'jackson_core_test/generate.dart';

const packageTests = 'test';
final jacksonCoreTests = join(packageTests, 'jackson_core_test');
final thirdParty = join(jacksonCoreTests, 'third_party');
final lib = join(thirdParty, 'lib');
final src = join(thirdParty, 'src');
final testLib = join(thirdParty, 'test_lib');
final testSrc = join(thirdParty, 'test_src');

/// Compares 2 [Config] objects using [expect] to give useful errors when
/// two fields are not equal.
void expectConfigsAreEqual(Config a, Config b) {
  expect(a.classes, equals(b.classes));
  expect(a.libraryName, equals(b.libraryName));
  expect(a.cRoot, equals(b.cRoot));
  expect(a.dartRoot, equals(b.dartRoot));
  expect(a.sourcePath, equals(b.sourcePath));
  expect(a.classPath, equals(b.classPath));
  expect(a.preamble, equals(b.preamble));
  expect(a.importMap, equals(b.importMap));
  final am = a.mavenDownloads;
  final bm = b.mavenDownloads;
  if (am != null) {
    expect(bm, isNotNull);
    expect(am.sourceDeps, bm!.sourceDeps);
    expect(am.sourceDir, bm.sourceDir);
    expect(am.jarOnlyDeps, bm.jarOnlyDeps);
    expect(am.jarDir, bm.jarDir);
  } else {
    expect(bm, isNull);
  }
  final aa = a.androidSdkConfig;
  final ba = b.androidSdkConfig;
  if (aa != null) {
    expect(ba, isNotNull);
    expect(aa.versions, ba!.versions);
    expect(aa.sdkRoot, ba.sdkRoot);
    expect(aa.includeSources, ba.includeSources);
  } else {
    expect(ba, isNull);
  }
  final aso = a.summarizerOptions;
  final bso = b.summarizerOptions;
  if (aso != null) {
    expect(bso, isNotNull);
    expect(aso.extraArgs, bso!.extraArgs);
    expect(aso.workingDirectory, bso.workingDirectory);
    expect(aso.backend, bso.backend);
  } else {
    expect(bso, isNull);
  }
}

void main() {
  final config = Config.parseArgs([
    '--config',
    join(jacksonCoreTests, 'jnigen.yaml'),
    '-Dc_root=$testSrc',
    '-Ddart_root=$testLib',
  ]);

  test('compare configuration values', () {
    expectConfigsAreEqual(config, getConfig(isTest: true));
  });
}
