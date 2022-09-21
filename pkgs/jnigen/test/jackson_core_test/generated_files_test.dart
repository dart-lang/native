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
  final thirdParty = join(packageTestsDir, testName, 'third_party');
  test("compare generated bindings for jackson_core", () async {
    final tempDir = await Directory(thirdParty).createTemp("test_");
    await generate(root: tempDir.path);

    compareDirs(join(thirdParty, 'lib'), join(tempDir.path, "lib"));
    compareDirs(join(thirdParty, 'src'), join(tempDir.path, "src"));
    tempDir.deleteSync(recursive: true);
  });
  Future<void> analyze(String path) async {
    final analyzeProc = await Process.start('dart', ['analyze', path],
        mode: ProcessStartMode.inheritStdio);
    final exitCode = await analyzeProc.exitCode;
    expect(exitCode, 0);
  }

  test(
      'generate and analyze bindings for complete library, '
      'not just required classes', () async {
    final tempDir = await Directory(thirdParty).createTemp("test_");
    await generate(root: tempDir.path, generateFullVersion: true);
    await analyze(tempDir.path);
    tempDir.deleteSync(recursive: true);
  }, timeout: Timeout(Duration(minutes: 2)));
  test('generate and analyze bindings using ASM', () async {
    final tempDir = await Directory(thirdParty).createTemp("test_");
    await generate(root: tempDir.path, generateFullVersion: true, useAsm: true);
    await analyze(tempDir.path);
    tempDir.deleteSync(recursive: true);
  }, timeout: Timeout(Duration(minutes: 2)));
}
