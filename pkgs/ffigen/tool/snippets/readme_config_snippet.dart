// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

// snippet-start
import 'dart:io';

import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../');
  final generator = FfiGenerator(
    // Required. Output path and options for the generated bindings.
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/src/generated_bindings.dart'),
      ),
    ),
    // Where to look for header files.
    input: Input(entryPoints: [packageRoot.resolve('src/my_header.h')]),
    // Visitors transform and filter AST nodes. By default, all top level APIs
    // are excluded from the bindings. You must explicitly include the APIs
    // you're interested in. Here we include all functions and structs.
    visitors: [
      Visitor(
        func: (node) => node.isIncluded = true,
        struct: (node) => node.isIncluded = true,
      ),
    ],
  );
  await generator.generate();
}
// snippet-end
