// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:ffigen/ffigen.dart';

void inputExamples(Uri packageRoot) {
  // snippet-start#missing_headers
  Input(
    entryPoints: [packageRoot.resolve('src/header.h')],
    compilerOptions: ['-I/path/to/folder'],
  );
  // snippet-end#missing_headers

  // snippet-start#ignore_source_errors
  Input(
    entryPoints: [packageRoot.resolve('src/header.h')],
    ignoreSourceErrors: true,
  );
  // snippet-end#ignore_source_errors
}
