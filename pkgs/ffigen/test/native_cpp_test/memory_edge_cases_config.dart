// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);
  final testDir = packageRoot.resolve('test/native_cpp_test/');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: testDir.resolve('memory_edge_cases_bindings.dart'),
      ),
      style: const NativeExternalBindings(assetId: 'package:ffigen/cpp_test'),
    ),
    input: Input(
      entryPoints: [testDir.resolve('memory_edge_cases.h')],
      compilerOptions: [
        // Work around the windows-2025-vs2026 runner having VS 2026 MSVC STL
        // headers with an older preinstalled LLVM.
        if (Platform.isWindows) '-D_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH',
      ],
      appendCompilerOptions: true,
    ),
    cpp: const Cpp(),
    visitors: [
      Visitor(
        cppClass: (node) {
          const include = {'Node', 'NodeManager', 'NodeContainer'};
          node.isIncluded = include.contains(node.originalName);
        },
      ),
    ],
  );
}
