// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// cd to project's root, and run -
// dart run tool/build_libclang.dart

import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _formatter = DartFormatter();

/// Used to mock the Clang class in ffigen.
/// Generates `lib/src/header_parser/clang_bindings/clang_wrapper.dart`.
void _generateClangClassWrapper(List<String> exportedFunctions) {
  final wrapperFunctions = exportedFunctions.map((func) {
    final funcAlias = func.replaceFirst(RegExp(r'_wrap'), '');
    return 'final $funcAlias = c.$func;';
  }).join('\n');

  final output = """
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// AUTO GENERATED FILE, DO NOT EDIT.
// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'clang_bindings.dart' as c;

class Clang {
$wrapperFunctions
}
""";

  File(p.joinAll([
    p.dirname(Platform.script.path),
    '..',
    'lib',
    'src',
    'header_parser',
    'clang_bindings',
    'clang_wrapper.dart'
  ])).writeAsStringSync(_formatter.format(output));
}

void _generateClangExports(String filePath, List<String> exportedFunctions) {
  // export malloc and free additionally to use to do memory
  // management in ffigenpad
  final functions = [...exportedFunctions, 'malloc', 'free']
      .map((func) => '_$func')
      .join('\n');
  File(filePath).writeAsStringSync(functions);
}

void _checkEmscriptenVersion() {
  final process = Process.runSync('emcc', ['--version']);
  final versionExp = RegExp(r'\d+.\d+.\d+');
  final version = versionExp.stringMatch(process.stdout.toString());
  if (version == null) {
    throw Exception('Failed to extract emscripten version.');
  }
  final versionList = version.split('.').map(int.parse).toList(growable: false);
  if (!(versionList[0] > 3 || versionList[1] > 1 || versionList[2] > 60)) {
    throw Exception('Upgrade to atleast v3.1.61 of emscripten to proceed.');
  }
  print('Acceptable emscripten version: $version');
}

void main(List<String> args) async {
  // Load the ffigen config for libclang to extract included functions.
  final configYaml = await File(p.join(
    p.dirname(Platform.script.path),
    'libclang_config.yaml',
  )).readAsString();
  final config = loadYaml(configYaml) as YamlMap;

  // Get the list of functions to be exported from libclang.
  final exportedFunctions =
      // ignore: avoid_dynamic_calls
      List<String>.from(config['functions']['include'] as YamlList);

  final libclangDir = p.joinAll(
    [p.dirname(Platform.script.path), '..', 'third_party', 'libclang'],
  );

  print('Writing third_party/libclang/libclang.exports');
  _generateClangExports(
    p.join(libclangDir, 'libclang.exports'),
    exportedFunctions,
  );

  print('Writing lib/src/header_parser/clang_wrapper.dart');
  _generateClangClassWrapper(exportedFunctions);

  print('Checking emscripten version');
  _checkEmscriptenVersion();

  print('Building bin/libclang.wasm');
  final archiveFiles =
      await Directory(p.join(libclangDir, 'llvm-project', 'lib'))
          .list(recursive: false)
          .map((file) => p.relative(file.path, from: libclangDir))
          .where((filepath) => filepath.endsWith('.a'))
          .toList();

  final result = await Process.run(
    'emcc',
    [
      ...archiveFiles,
      'wrapper.c',
      '-I./llvm-project/include',
      '-o',
      '../../bin/libclang.mjs',
      '--no-entry',
      '-sALLOW_MEMORY_GROWTH',
      '-sALLOW_TABLE_GROWTH',
      '-sWASM_BIGINT',
      '-sENVIRONMENT=web,worker',
      '--embed-file',
      './llvm-project/lib/clang@/lib/clang',
      '-sEXPORTED_FUNCTIONS=@libclang.exports',
      '-sFS_DEBUG',
      // ignore: lines_longer_than_80_chars
      '-sEXPORTED_RUNTIME_METHODS=FS,wasmExports,wasmMemory,addFunction,removeFunction',
      // used for production builds
      if (args.contains('--optimize')) ...['-O3', '-lexports.js']
    ],
    workingDirectory: libclangDir,
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
