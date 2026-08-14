// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain_c/src/utils/env_from_bat.dart';
import 'package:test/test.dart';

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
}
