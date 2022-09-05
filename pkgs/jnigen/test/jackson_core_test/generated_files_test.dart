// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' hide equals;

import 'package:test/test.dart';

import '../test_util/test_util.dart';
import 'generate.dart';

const packageTestsDir = 'test';
const testName = 'jackson_core_test';

void main() async {
  final generatedFilesRoot = join(packageTestsDir, testName, 'third_party');
  await generate(isTest: true);
  test("compare generated bindings for jackson_core", () {
    compareDirs(
        join(generatedFilesRoot, 'lib'), join(generatedFilesRoot, 'test_lib'));
    compareDirs(
        join(generatedFilesRoot, 'src'), join(generatedFilesRoot, 'test_src'));
  });
  Future<void> analyze() async {
    final analyzeProc = await Process.start(
        'dart', ['analyze', join('test', testName, 'third_party', 'test_lib')],
        mode: ProcessStartMode.inheritStdio);
    final exitCode = await analyzeProc.exitCode;
    expect(exitCode, 0);
  }

  test(
      'generate and analyze bindings for complete library, '
      'not just required classes', () async {
    await generate(isTest: true, generateFullVersion: true);
    await analyze();
  }, timeout: Timeout(Duration(minutes: 2)));
  test('generate and analyze bindings using ASM', () async {
    await generate(isTest: true, generateFullVersion: true, useAsm: true);
    await analyze();
  }, timeout: Timeout(Duration(minutes: 2)));
  tearDown(() async {
    for (var dirName in ['test_lib', 'test_src']) {
      final dir = Directory(join('test', testName, 'third_party', dirName));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  });
}
