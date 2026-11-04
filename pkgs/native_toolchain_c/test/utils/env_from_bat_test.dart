// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_toolchain_c/src/utils/env_from_bat.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'fake_process_manager.dart';

void main() {
  test('parses added and changed variables from output', () async {
    // [environmentFromBatchFile] dumps `set` before and after running the batch
    // file, separated by `=======`, and reports the entries that were added or
    // changed. Each half is a sequence of `KEY=value` lines separated by CRLF.
    const before = 'EXISTING=old\r\nCHANGED=1';
    const after = 'EXISTING=old\r\nCHANGED=2\r\nNEWVAR=NEWVALUE';
    final processManager = FakeProcessManager([
      const FakeCommand(stdout: '$before\r\n=======\r\n$after'),
    ]);

    final result = await environmentFromBatchFile(
      Uri.file('C:/some/path/vcvars64.bat'),
      processManager: processManager,
    );

    // `EXISTING` is unchanged, so it is dropped. `CHANGED` differs and `NEWVAR`
    // is new, so both are reported.
    expect(result, {'CHANGED': '2', 'NEWVAR': 'NEWVALUE'});
  });

  test('runs the batch file by a path relative to its directory', () async {
    final processManager = FakeProcessManager([
      const FakeCommand(stdout: '=======\r\n'),
    ]);

    await environmentFromBatchFile(
      Uri.file('C:/some/path/vcvars64.bat'),
      processManager: processManager,
    );

    // A bare `vcvars64.bat` isn't found if `NoDefaultCurrentDirectoryInExePath`
    // is set.
    expect(
      processManager.invocations.single.command.single,
      contains(r'&& .\vcvars64.bat '),
    );
  });

  test('throws if running the batch file fails', () async {
    // If the batch file fails, the trailing `set` doesn't run, so there is no
    // environment to report.
    final processManager = FakeProcessManager([
      const FakeCommand(
        stdout: 'EXISTING=old\r\n=======\r\n',
        stderr: "'vcvars64.bat' is not recognized",
        exitCode: 1,
      ),
    ]);

    await expectLater(
      environmentFromBatchFile(
        Uri.file('C:/some/path/vcvars64.bat'),
        processManager: processManager,
      ),
      throwsA(
        isA<ProcessException>()
            .having((e) => e.errorCode, 'errorCode', 1)
            .having(
              (e) => e.message,
              'message',
              contains("'vcvars64.bat' is not recognized"),
            ),
      ),
    );
  });

  test(
    'finds the batch file if NoDefaultCurrentDirectoryInExePath is set',
    () async {
      if (!Platform.isWindows) {
        // Running a batch file needs cmd.exe.
        return;
      }
      final tempUri = await tempDirForTest();
      final batchFile = File.fromUri(tempUri.resolve('set_env.bat'));
      await batchFile.writeAsString('@set NTC_ENV_FROM_BAT_TEST=%1\r\n');

      final result = await environmentFromBatchFile(
        batchFile.uri,
        arguments: ['hello'],
        processManager:
            const NoDefaultCurrentDirectoryInExePathProcessManager(),
      );

      expect(result, {'NTC_ENV_FROM_BAT_TEST': 'hello'});
    },
  );
}
