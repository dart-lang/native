// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;

ProcessResult runFfigenForConfig(String configPath) {
  return Process.runSync(p.join(sdkPath, 'bin', 'dart'), [
    'run',
    'ffigen',
    '--config=$configPath',
  ], runInShell: Platform.isWindows);
}

void main() {
  final configPaths = [
    'ffigen_configs/base.yaml',
    'ffigen_configs/a.yaml',
    'ffigen_configs/a_shared_base.yaml',
  ];
  for (final configPath in configPaths) {
    final res = runFfigenForConfig(configPath);
    print(res.stdout.toString());
    if (res.exitCode != 0) {
      throw Exception('Some error occurred: ${res.stderr.toString()}');
    }
  }
}
