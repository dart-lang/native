// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unreachable_from_main

// snippet-start
import 'dart:io';

import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../');
  final generator = FfiGenerator(
    // Required. Output path for the generated bindings.
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('lib/add.g.dart')),
    ),
    // Optional. Where to look for header files.
    input: Input(entryPoints: [packageRoot.resolve('src/add.h')]),
    // Optional. Transform and filter AST nodes.
    visitors: [Visitor(func: (node) => node.isIncluded = node.name == 'add')],
  );
  await generator.generate();
}
// snippet-end

FfiGenerator getConfig(Uri packageRoot) => FfiGenerator(
  output: Output(dart: DartOutput(path: packageRoot.resolve('lib/add.g.dart'))),
  input: Input(entryPoints: [packageRoot.resolve('src/add.h')]),
  visitors: [Visitor(func: (node) => node.isIncluded = node.name == 'add')],
);
