// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

const inputFile = 'src/objective_c.c';
const outputFile = 'test/objective_c.dylib';

void _buildLib(String input, String output) {
  final args = [
    '-shared',
    '-fpic',
    input,
    '-I',
    'src',
    '-o',
    output,
  ];
  const exec = 'clang';
  print('Running: $exec ${args.join(" ")}');
  final proc = Process.runSync(exec, args);
  if (proc.exitCode != 0) {
    exitCode = proc.exitCode;
    print(proc.stdout);
    print(proc.stderr);
    throw Exception('Command failed: $exec ${args.join(" ")}');
  }
  print('Generated $output');
}

void main() {
  Directory.current = Platform.script.resolve('..').path;
  _buildLib(inputFile, outputFile);
}
