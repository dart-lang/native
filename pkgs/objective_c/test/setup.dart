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

final cFiles = [
  'src/objective_c.c',
  'src/include/dart_api_dl.c',
  'test/util.c',
].map(_resolve);
final cMain = _resolve('test/main.c');
final objCFiles = [
  'src/input_stream_adapter.m',
  'src/objective_c.m',
  'src/objective_c_bindings_generated.m',
  'src/proxy.m',
].map(_resolve);
const objCFlags = [
  '-x',
  'objective-c',
  '-fobjc-arc',
];
final outputFile = _resolve('test/objective_c.dylib');

final _repoDir = () {
  var path = Platform.script;
  while (path.pathSegments.isNotEmpty) {
    path = path.resolve('..');
    if (Directory(path.resolve('.git').toFilePath()).existsSync()) {
      return path;
    }
  }
  throw Exception("Can't find .git dir above ${Platform.script}");
}();
final _pkgDir = _repoDir.resolve('pkgs/objective_c/');
String _resolve(String file) => _pkgDir.resolve(file).toFilePath();

void _runClang(List<String> flags, String output) {
  final args = [
    ...flags,
    '-o',
    output,
  ];
  const exec = 'clang';
  print('Running: $exec ${args.join(" ")}');
  final proc = Process.runSync(exec, args);
  print(proc.stdout);
  print(proc.stderr);
  if (proc.exitCode != 0) {
    exitCode = proc.exitCode;
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

void _linkMain(List<String> inputs, String output) =>
    _runClang(['-dead_strip', '-fobjc-arc', ...inputs], output);

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addFlag('main-thread-dispatcher');
  final args = parser.parse(arguments);

  final flags = [
    if (!args.flag('main-thread-dispatcher')) '-DNO_MAIN_THREAD_DISPATCH',
  ];
  final objFiles = <String>[
    for (final src in cFiles) _buildObject(src, flags),
    for (final src in objCFiles) _buildObject(src, [...objCFlags, ...flags]),
  ];
  _linkLib(objFiles, outputFile);

  // Sanity check that the dylib was created correctly.
  final lib = DynamicLibrary.open(outputFile);
  lib.lookup('DOBJC_disposeObjCBlockWithClosure'); // objective_c.c
  lib.lookup('DOBJC_runOnMainThread'); // objective_c.m
  lib.lookup('Dart_InitializeApiDL'); // dart_api_dl.c
  lib.lookup('OBJC_CLASS_\$_DOBJCDartProxy'); // proxy.m
  // objective_c_bindings_generated.m
  lib.lookup('_ObjectiveCBindings_wrapListenerBlock_ovsamd');

  // Sanity check that the executable can find FFI symbols.
  _linkMain([...objFiles, cMain], '$cMain.exe');
  final result = Process.runSync('$cMain.exe', []);
  if (result.exitCode != 0) {
    throw Exception('Missing symbols from executable:\n${result.stderr}');
  }
}
