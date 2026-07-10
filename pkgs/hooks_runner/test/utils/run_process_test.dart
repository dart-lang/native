// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for running commands whose executable path or arguments
// contain a space (e.g. the default pub cache under a Windows user name with
// a space, `C:\Users\First Last\AppData\Local\Pub\Cache\...`).
//
// On Windows, `runProcess` runs through `cmd.exe` (`runInShell`) whenever a
// `workingDirectory` is passed. `cmd.exe`'s `/c` quote-stripping rule mangles
// the command line as soon as more than one token needs quoting because it
// contains a space (the executable path and an argument, or two arguments),
// causing errors like
// `'C:\Program' is not recognized as an internal or external command`.

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  late Uri scriptUri;

  setUpAll(() async {
    final scriptDir = await tempDirForTest();
    scriptUri = scriptDir.resolve('echo_args.dart');
    await File.fromUri(scriptUri).writeAsString('''
void main(List<String> args) {
  print('ARGC:\${args.length}');
  print('ARGV:\${args.join('|')}');
}
''');
  });

  test(
    'runProcess handles an executable path containing a space',
    timeout: const Timeout.factor(5),
    () async {
      final outDir = await tempDirForTest();
      final exeUri = outDir.resolve(
        'echo args${Platform.isWindows ? '.exe' : ''}',
      );
      final compileResult = await Process.run(Platform.resolvedExecutable, [
        'compile',
        'exe',
        scriptUri.toFilePath(),
        '-o',
        exeUri.toFilePath(),
      ]);
      expect(compileResult.exitCode, 0, reason: '${compileResult.stderr}');

      final workingDir = await tempDirForTest();
      final result = await runProcess(
        executable: exeUri,
        arguments: ['an argument with spaces'],
        workingDirectory: workingDir,
        logger: logger,
      );

      expect(result.exitCode, 0);
      expect(result.stdout, contains('ARGC:1'));
      expect(result.stdout, contains('ARGV:an argument with spaces'));
    },
  );

  test('runProcess handles arguments containing a space', () async {
    final workingDir = await tempDirForTest();
    final result = await runProcess(
      executable: Uri.file(Platform.resolvedExecutable),
      arguments: [scriptUri.toFilePath(), 'first arg', 'second arg'],
      workingDirectory: workingDir,
      logger: logger,
    );

    expect(result.exitCode, 0);
    expect(result.stdout, contains('ARGC:2'));
    expect(result.stdout, contains('ARGV:first arg|second arg'));
  });

  test('runProcess handles arguments containing a space and quotes', () async {
    final workingDir = await tempDirForTest();
    final result = await runProcess(
      executable: Uri.file(Platform.resolvedExecutable),
      arguments: [scriptUri.toFilePath(), 'fir"st arg', 'sec\'ond arg'],
      workingDirectory: workingDir,
      logger: logger,
    );

    expect(result.exitCode, 0);
    expect(result.stdout, contains('ARGC:2'));
    expect(result.stdout, contains('ARGV:fir"st arg|sec\'ond arg'));
  });
}
