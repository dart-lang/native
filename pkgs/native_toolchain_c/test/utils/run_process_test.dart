// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final whichUri = Uri.file(Platform.isWindows ? 'where' : 'which');

  test('log contains working dir', () async {
    await inTempDir((tempUri) async {
      final messages = <String>[];
      await runProcess(
        executable: whichUri,
        workingDirectory: tempUri,
        logger: createCapturingLogger(messages),
      );
      expect(messages.join('\n'), contains('cd'));
    });
  });

  test('log contains env', () async {
    final messages = <String>[];
    await runProcess(
      executable: whichUri,
      environment: {'FOO': 'BAR'},
      logger: createCapturingLogger(messages),
    );
    expect(messages.join('\n'), contains('FOO=BAR'));
  });

  test('stderr', () async {
    final messages = <String>[];
    const filePath = 'a/dart/file/which/does/not/exist.dart';
    final result = await runProcess(
      executable: Uri.file(Platform.resolvedExecutable),
      arguments: [filePath],
      logger: createCapturingLogger(messages),
    );
    expect(result.stderr, contains(filePath));
    expect(result.toString(), contains(filePath));
  });
}
