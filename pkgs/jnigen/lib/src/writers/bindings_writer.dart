// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/logging/logging.dart';

abstract class BindingsWriter {
  Future<void> writeBindings(Iterable<ClassDecl> classes);

  /// Run dart format command on [path].
  static Future<void> runDartFormat(String path) async {
    log.info('Running dart format...');
    final formatRes = await Process.run('dart', ['format', path]);
    // if negative exit code, likely due to an interrupt.
    if (formatRes.exitCode > 0) {
      log.fatal('Dart format completed with exit code ${formatRes.exitCode} '
          'This usually means there\'s a syntax error in bindings.\n'
          'Please look at the generated files and report a bug.');
    }
  }
}
