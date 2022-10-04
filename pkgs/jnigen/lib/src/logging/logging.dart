// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:logging/logging.dart';

const _ansiRed = '\x1b[31m';
const _ansiDefault = '\x1b[39;49m';

Logger log = Logger('jnigen');

void setLoggingLevel(Level level) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((r) {
    var message = '(${r.loggerName}) ${r.level.name}: ${r.message}';
    if (level == Level.SHOUT || level == Level.SEVERE) {
      message = '$_ansiRed$message$_ansiDefault';
    }
    stderr.writeln(message);
  });
}

void printError(Object? message) {
  if (stderr.supportsAnsiEscapes) {
    message = '$_ansiRed$message$_ansiDefault';
  }
  stderr.writeln(message);
}

extension FatalErrors on Logger {
  void fatal(Object? message, {int exitCode = 2}) {
    message = '${_ansiRed}Fatal: $message$_ansiDefault';
    stderr.writeln(message);
    exit(exitCode);
  }
}
