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

import 'package:args/args.dart';

const cFiles = ['src/objective_c.c', 'src/include/dart_api_dl.c'];
const objCFiles = ['src/objective_c.m', 'src/proxy.m'];
const objCFlags = [
  '-x',
  'objective-c',
  '-fobjc-arc',
  '-framework',
  'Foundation'
];
const outputFile = 'test/objective_c.dylib';

void _runClang(List<String> flags, String output) {
  final args = [
    ...flags,
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

String _buildObject(String input, List<String> flags) {
  final output = '$input.o';
  _runClang([...flags, '-c', input, '-fpic', '-I', 'src'], output);
  return output;
}

void _linkLib(List<String> inputs, String output) =>
    _runClang(['-shared', '-undefined', 'dynamic_lookup', ...inputs], output);

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addFlag('main-thread-dispatcher');
  final args = parser.parse(arguments);

  final flags = [
    if (!args.flag('main-thread-dispatcher')) '-DNO_MAIN_THREAD_DISPATCH',
  ];
  Directory.current = Platform.script.resolve('..').path;
  final objFiles = <String>[
    for (final src in cFiles) _buildObject(src, flags),
    for (final src in objCFiles) _buildObject(src, [...objCFlags, ...flags]),
  ];
  _linkLib(objFiles, outputFile);

  // Sanity check that the dylib was created correctly.
  final lib = DynamicLibrary.open(outputFile);
  lib.lookup('disposeObjCBlockWithClosure'); // objective_c.c
  lib.lookup('runOnMainThread'); // objective_c.m
  lib.lookup('Dart_InitializeApiDL'); // dart_api_dl.c
  lib.lookup('OBJC_CLASS_\$_DartProxy'); // proxy.m
}
