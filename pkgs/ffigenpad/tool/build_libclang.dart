// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// cd to project's root, and run -
// dart run tool/build_libclang.dart

import "dart:io";
import 'package:path/path.dart' as p;
import "package:yaml/yaml.dart";

void main() async {
  // Load the ffigen config for libclang
  final configYaml = await File(p.join(
    p.dirname(Platform.script.path),
    'libclang_config.yaml',
  )).readAsString();
  final config = loadYaml(configYaml);

  // Get the list of functions to be exported from libclang
  final exportedFunctions = List<String>.from(config["functions"]["include"]);

  final libclangDir = p.joinAll(
    [p.dirname(Platform.script.path), '..', 'third_party', 'libclang'],
  );

  print("Writing third_party/libclang/bin/libclang.exports");
  await File(p.joinAll([
    libclangDir,
    'bin',
    'libclang.exports',
  ])).writeAsString([...exportedFunctions, "malloc", "free"]
      .map((func) => "_$func")
      .join("\n"));

  print("Writing lib/src/header_parser/clang_wrapper.dart");
  _generateClangClassWrapper(exportedFunctions);

  final archiveFiles =
      await Directory(p.join(libclangDir, 'llvm-project', 'install', 'lib'))
          .list(recursive: false)
          .map((file) => p.relative(file.path, from: libclangDir))
          .where((filepath) => filepath.endsWith(".a"))
          .toList();

  final result = await Process.run(
    "emcc",
    [
      ...archiveFiles,
      "wrapper.c",
      "-I./llvm-project/install/include",
      "-o",
      "bin/libclang.mjs",
      "--no-entry",
      "-sALLOW_MEMORY_GROWTH",
      "-sALLOW_TABLE_GROWTH",
      "-sWASM_BIGINT",
      "--preload-file",
      "./llvm-project/install/lib/clang@/lib/clang",
      "-sEXPORTED_FUNCTIONS=@bin/libclang.exports",
      "-sEXPORTED_RUNTIME_METHODS=FS,wasmExports,wasmMemory,addFunction,removeFunction"
    ],
    workingDirectory: libclangDir,
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}

void _generateClangClassWrapper(List<String> exportedFunctions) async {
  const preamble = """
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// AUTO GENERATED FILE, DO NOT EDIT.
// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'clang_bindings.dart' as c;

class Clang {
""";

  final wrapperFunctions = exportedFunctions.map((func) {
    final funcAlias = func.endsWith("_wrap")
        ? func.substring(0, func.length - "_wrap".length)
        : func;
    return "  final $funcAlias = c.$func;";
  }).join("\n");

  await File(p.joinAll([
    p.dirname(Platform.script.path),
    '..',
    'lib',
    'src',
    'header_parser',
    'clang_bindings',
    'clang_wrapper.dart'
  ])).writeAsString("$preamble$wrapperFunctions\n}");
}
