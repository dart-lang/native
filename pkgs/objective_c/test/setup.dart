// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// When users import package:objective_c as a plugin, Flutter builds our native
// code automatically. But we want to be able to run tests using `dart test`, so
// we can't use Flutter's build system. So this script builds a dylib containing
// all that native code.

// ignore_for_file: avoid_print

import 'dart:ffi';
import 'dart:io';

const inputFiles = ['src/objective_c.c', 'src/include/dart_api_dl.c'];
const outputFile = 'test/objective_c.dylib';

void _buildLib(List<String> inputs, String output) {
  final args = [
    '-shared',
    '-fpic',
    ...inputs,
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
  _buildLib(inputFiles, outputFile);

  // Sanity check that the dylib was created correctly.
  DynamicLibrary.open(outputFile).lookup('disposeObjCBlockWithClosure');
}
