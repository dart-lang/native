// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

Future<bool> generateSymbolGraph(String swiftFile, String outputDir) async {
  final result = await Process.run(
    'swiftc',
    [
      swiftFile,
      '-emit-module',
      '-emit-symbol-graph',
      '-emit-symbol-graph-dir',
      outputDir,
    ],
  );
  if (result.exitCode != 0) {
    print("Error generating symbol graph");
    print(result.stdout);
    print(result.stderr);
    return false;
  }
  return true;
}
