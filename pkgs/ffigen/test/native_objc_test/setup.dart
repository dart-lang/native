// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

// All ObjC source files are compiled with ARC enabled except these.
const arcDisabledFiles = <String>{
  'ref_count_test.m',
};

Future<void> _runClang(List<String> flags, String output) async {
  final args = [...flags, '-o', output];
  final process = await Process.start('clang', args);
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException('clang', args, 'Build failed', result);
  }
  print('Generated file: $output');
}

Future<String> _buildObject(String input) async {
  final output = '$input.o';
  await _runClang([
    '-x',
    'objective-c',
    if (!arcDisabledFiles.contains(input)) '-fobjc-arc',
    '-Wno-nullability-completeness',
    '-c',
    input,
    '-fpic',
  ], output);
  return output;
}

Future<void> _linkLib(List<String> inputs, String output) => _runClang([
      '-shared',
      '-framework',
      'Foundation',
      '-undefined',
      'dynamic_lookup',
      ...inputs,
    ], output);

Future<void> _buildLib(List<String> inputs, String output) async {
  final objFiles = <String>[];
  for (final input in inputs) {
    objFiles.add(await _buildObject(input));
  }
  await _linkLib(objFiles, output);
}

Future<void> _buildSwift(
    String input, String outputHeader, String outputLib) async {
  final args = [
    '-c',
    input,
    '-emit-objc-header-path',
    outputHeader,
    '-emit-library',
    '-o',
    outputLib,
  ];
  final process = await Process.start('swiftc', args);
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException('swiftc', args, 'Build failed', result);
  }
  print('Generated files: $outputHeader and $outputLib');
}

Future<void> _runDart(List<String> args) async {
  final process =
      await Process.start(Platform.executable, args, workingDirectory: '../..');
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException('dart', args, 'Running Dart command', result);
  }
}

Future<void> _generateBindings(String config) async {
  await _runDart([
    'run',
    'ffigen',
    '--config',
    'test/native_objc_test/$config',
  ]);
  print('Generated bindings for: $config');
}

List<String> _getTestNames() {
  const configSuffix = '_config.yaml';
  final names = <String>[];
  for (final entity in Directory.current.listSync()) {
    final filename = entity.uri.pathSegments.last;
    if (filename.endsWith(configSuffix)) {
      names.add(filename.substring(0, filename.length - configSuffix.length));
    }
  }
  return names;
}

Future<void> build(List<String> testNames) async {
  // Swift build comes first because the generated header is consumed by ffigen.
  print('Building Dynamic Library and Header for Swift Tests...');
  for (final name in testNames) {
    final swiftFile = '${name}_test.swift';
    if (File(swiftFile).existsSync()) {
      await _buildSwift(
          swiftFile, '${name}_test-Swift.h', '${name}_test.dylib');
    }
  }

  // Ffigen comes next because it may generate an ObjC file that is compiled
  // into the dylib.
  // print('Generating Bindings for Objective C Native Tests...');
  for (final name in testNames) {
    await _generateBindings('${name}_config.yaml');
  }

  // Finally we build the dylib containing all the ObjC test code.
  print('Building Dynamic Library for Objective C Native Tests...');
  final mFiles = <String>[];
  for (final name in _getTestNames()) {
    final mFile = '${name}_test.m';
    if (File(mFile).existsSync()) mFiles.add(mFile);
    final bindingMFile = '${name}_bindings.m';
    if (File(bindingMFile).existsSync()) mFiles.add(bindingMFile);
  }
  if (mFiles.isNotEmpty) {
    await _buildLib(mFiles, 'objc_test.dylib');
  }
}

Future<void> clean(List<String> testNames) async {
  print('Deleting generated and built files...');
  final filenames = [
    for (final name in testNames) ...[
      '${name}_bindings.dart',
      '${name}_bindings.m',
      '${name}_bindings.o',
      '${name}_test_bindings.dart',
      '${name}_test.o',
    ],
    'objc_test.dylib',
  ];
  for (final filename in filenames) {
    final file = File(filename);
    if (file.existsSync()) file.deleteSync();
  }
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addFlag('clean');
  parser.addFlag('main-thread-dispatcher');
  final args = parser.parse(arguments);

  // Allow running this script directly from any path (or an IDE).
  Directory.current = Platform.script.resolve('.').toFilePath();
  if (!Platform.isMacOS) {
    throw const OSError('Objective C tests are only supported on MacOS');
  }

  if (args.flag('clean')) {
    return await clean(_getTestNames());
  }

  await _runDart([
    '../objective_c/test/setup.dart',
    if (args.flag('main-thread-dispatcher')) '--main-thread-dispatcher',
  ]);
  return await build(args.rest.isNotEmpty ? args.rest : _getTestNames());
}
