// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);
  final testDir = packageRoot.resolve('test/native_test/');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: testDir.resolve('_expected_native_test_bindings.dart'),
      ),
      style: const NativeExternalBindings(
        assetId: 'package:ffigen/native_test',
      ),
    ),
    input: Input(
      entryPoints: [testDir.resolve('native_test.c')],
      include: (header) => header.path.endsWith('native_test.c'),
    ),
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
        union: (node) => node.isIncluded = true,
        global: (node) => node.isIncluded = true,
        enumClass: (node) {
          node.isIncluded = true;
          node.silenceWarning = true;
          if (node.name == 'Enum2') {
            node.style = EnumStyle.intConstants;
          }
        },
        macroConstant: (node) => node.isIncluded = true,
        typealias: (node) => node.isIncluded = TypealiasInclude.always,
      ),
    ],
  );
}
