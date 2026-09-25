// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: unused_local_variable

// snippet-start#configuration
import 'dart:io';

import 'package:jnigen/jnigen.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../');
  final generator = JniGenerator(
    // Required. Output path and structure for the generated bindings.
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/src/generated_bindings.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    // Where to find Java classes and source files.
    input: Input(
      // Required. Fully-qualified names of classes or packages to generate bindings for.
      classes: ['com.example.MyClass'],
      // Optional. Directories to search for Java source files.
      sourcePath: [packageRoot.resolve('android/app/src/main/java')],
    ),
  );
  await generator.generate();
}
// snippet-end#configuration

Future<void> generateBuiltInTypes(Uri packageRoot) async {
  // snippet-start#built_in_types
  final generator = JniGenerator(
    input: Input(
      classes: [
        'java.time.Instant',
        'java.time.ZoneOffset',
        'java.time.ZonedDateTime',
        'java.lang.Math',
        // 'java.lang.Integer', // Will error, already included in binary
      ],
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/gen/'),
      ),
    ),
  );
  await generator.generate();
  // snippet-end#built_in_types
}
