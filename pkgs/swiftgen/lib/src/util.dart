// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

Future<void> run(
  String executable,
  List<String> arguments,
  String workingDir,
) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDir,
  );
  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);
  if ((await process.exitCode) != 0) {
    throw ProcessException(executable, arguments);
  }
}

Uri createTempDirectory() =>
    Uri.directory(Directory.systemTemp.createTempSync().path);
