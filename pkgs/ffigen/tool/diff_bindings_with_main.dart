// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  final scriptDir = path.dirname(Platform.script.toFilePath());
  final shScript = path.join(scriptDir, 'diff_bindings_with_main.sh');
  final targetArgs = args.isEmpty
      ? ['../objective_c/lib/src/objective_c_bindings_generated.dart']
      : args;

  final result = await Process.run(
    '/bin/bash',
    [shScript, ...targetArgs],
    workingDirectory: path.dirname(scriptDir),
  );

  if (result.stdout.toString().isNotEmpty) {
    stdout.write(result.stdout);
  }
  if (result.stderr.toString().isNotEmpty) {
    stderr.write(result.stderr);
  }
  exitCode = result.exitCode;
}
