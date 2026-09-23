// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

// snippet-start#main
import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final generator = FfiGenerator(
    output: Output(dart: DartOutput(path: Uri.file('lib/bindings.dart'))),
    input: Input(entryPoints: [Uri.file('src/my_c_header.h')]),
    visitors: [Visitor(func: (node) => node.isIncluded = true)],
  );
  await generator.generate();
}
// snippet-end#main
