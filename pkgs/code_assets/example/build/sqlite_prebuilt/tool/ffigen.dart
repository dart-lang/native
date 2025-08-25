// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  FfiGen().run(
    Config(
      entryPoints: [packageRoot.resolve('third_party/sqlite/sqlite3.h')],
      output: packageRoot.resolve('lib/src/third_party/sqlite3.g.dart'),
      preamble: '''
// The author disclaims copyright to this source code.  In place of
// a legal notice, here is a blessing:
//
//    May you do good and not evil.
//    May you find forgiveness for yourself and forgive others.
//    May you share freely, never taking more than you give.

''',
      ffiNativeConfig: const FfiNativeConfig(enabled: true),
      functionDecl: DeclarationFilters(
        shouldInclude: (declaration) {
          const include = {'sqlite3_libversion'};
          return include.contains(declaration.originalName);
        },
      ),
    ),
  );
}
