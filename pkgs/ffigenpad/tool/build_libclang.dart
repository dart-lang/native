// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  exportedFunctions.addAll(["malloc", "free"]);

  final libclangDir = p.joinAll(
    [p.dirname(Platform.script.path), '..', 'third_party', 'libclang'],
  );
  print("Writing libclang.exports");
  await File(p.joinAll([
    libclangDir,
    'bin',
    'libclang.exports',
  ])).writeAsString(exportedFunctions.map((func) => "_$func").join("\n"));

  final result = await Process.run(
    "emcc",
    [
      "./llvm-project/install/lib/*.a",
      "./wrapper.c",
      "-I./llvm-project/install/include",
      "-o",
      "./bin/libclang.mjs",
      "--no-entry",
      "-sALLOW_MEMORY_GROWTH",
      "-sALLOW_TABLE_GROWTH",
      "-sEXPORTED_FUNCTIONS=@./bin/libclang.exports",
      "-sEXPORTED_RUNTIME_METHODS=ccall,FS,wasmExports,addFunction"
    ],
    workingDirectory: libclangDir,
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
