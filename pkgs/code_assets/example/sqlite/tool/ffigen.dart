// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    headers: Headers(
      entryPoints: [packageRoot.resolve('third_party/sqlite/sqlite3.h')],
    ),
    functions: Functions(
      include: (decl) => {'sqlite3_libversion'}.contains(decl.originalName),
      recordUse: (_) => true,
    ),
    output: Output(
      dartFile: packageRoot.resolve('lib/src/third_party/sqlite3.g.dart'),
      recordUseMapping: packageRoot.resolve(
        'lib/src/third_party/record_use_mapping.dart',
      ),
      preamble: '''
// The author disclaims copyright to this source code.  In place of
// a legal notice, here is a blessing:
//
//    May you do good and not evil.
//    May you find forgiveness for yourself and forgive others.
//    May you share freely, never taking more than you give.

''',
    ),
  ).generate();
}
