// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/config/config.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' hide equals;
import 'package:path/path.dart' as path show equals;

import 'jackson_core_test/generate.dart';

const packageTests = 'test';
final jacksonCoreTests = join(packageTests, 'jackson_core_test');
final thirdParty = join(jacksonCoreTests, 'third_party');
final lib = join(thirdParty, 'lib');
final src = join(thirdParty, 'src');
final testLib = join(thirdParty, 'test_', 'lib');
final testSrc = join(thirdParty, 'test_', 'src');

/// Compares 2 [Config] objects using [expect] to give useful errors when
/// two fields are not equal.
void expectConfigsAreEqual(Config a, Config b) {
  expect(a.classes, equals(b.classes), reason: "classes");
  expect(a.outputConfig.cConfig.libraryName,
      equals(b.outputConfig.cConfig.libraryName),
      reason: "libraryName");
  expect(a.outputConfig.cConfig.path, equals(b.outputConfig.cConfig.path),
      reason: "cRoot");
  expect(a.outputConfig.dartConfig.path, equals(b.outputConfig.dartConfig.path),
      reason: "dartRoot");
  expect(a.sourcePath, equals(b.sourcePath), reason: "sourcePath");
  expect(a.classPath, equals(b.classPath), reason: "classPath");
  expect(a.preamble, equals(b.preamble), reason: "preamble");
  expect(a.importMap, equals(b.importMap), reason: "importMap");
  final am = a.mavenDownloads;
  final bm = b.mavenDownloads;
  if (am != null) {
    expect(bm, isNotNull);
    expect(am.sourceDeps, bm!.sourceDeps, reason: "mavenDownloads.sourceDeps");
    expect(path.equals(am.sourceDir, bm.sourceDir), isTrue,
        reason: "mavenDownloads.sourceDir");
    expect(am.jarOnlyDeps, bm.jarOnlyDeps,
        reason: "mavenDownloads.jarOnlyDeps");
    expect(path.equals(am.jarDir, bm.jarDir), isTrue,
        reason: "mavenDownloads.jarDir");
  } else {
    expect(bm, isNull, reason: "mavenDownloads");
  }
  final aa = a.androidSdkConfig;
  final ba = b.androidSdkConfig;
  if (aa != null) {
    expect(ba, isNotNull, reason: "androidSdkConfig");
    expect(aa.versions, ba!.versions, reason: "androidSdkConfig.versions");
    expect(aa.sdkRoot, ba.sdkRoot, reason: "androidSdkConfig.sdkRoot");
    expect(aa.includeSources, ba.includeSources,
        reason: "androidSdkConfig.includeSources");
  } else {
    expect(ba, isNull, reason: "androidSdkConfig");
  }
  final aso = a.summarizerOptions;
  final bso = b.summarizerOptions;
  if (aso != null) {
    expect(bso, isNotNull, reason: "summarizerOptions");
    expect(aso.extraArgs, bso!.extraArgs,
        reason: "summarizerOptions.extraArgs");
    expect(aso.workingDirectory, bso.workingDirectory,
        reason: "summarizerOptions.workingDirectory");
    expect(aso.backend, bso.backend, reason: "summarizerOptions.backend");
  } else {
    expect(bso, isNull, reason: "summarizerOptions");
  }
}

void main() {
  final config = Config.parseArgs([
    '--config',
    join(jacksonCoreTests, 'jnigen.yaml'),
    '-Doutput.c.path=$testSrc/',
    '-Doutput.dart.path=$testLib/',
  ]);

  test('compare configuration values', () {
    expectConfigsAreEqual(config, getConfig(root: join(thirdParty, 'test_')));
  });
}
