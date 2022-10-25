// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:logging/logging.dart';

const _ansiRed = '\x1b[31m';
const _ansiYellow = '\x1b[33m';
const _ansiDefault = '\x1b[39;49m';

String _colorize(String message, String colorCode) {
  if (stderr.supportsAnsiEscapes) {
    return '$colorCode$message$_ansiDefault';
  }
  return message;
}

Logger log = Logger('jnigen');

/// Set logging level to [level] and initialize the logger.
void setLoggingLevel(Level level) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((r) {
    var message = '(${r.loggerName}) ${r.level.name}: ${r.message}';
    if ((r.level == Level.SHOUT || r.level == Level.SEVERE)) {
      message = _colorize(message, _ansiRed);
    } else if (r.level == Level.WARNING) {
      message = _colorize(message, _ansiYellow);
    }
    stderr.writeln(message);
  });
}

/// Prints [message] without logging information.
///
/// Primarily used in printing output of failed commands.
void printError(Object? message) {
  stderr.writeln(_colorize(message.toString(), _ansiRed));
}

extension FatalErrors on Logger {
  void fatal(Object? message, {int exitCode = 2}) {
    message = _colorize('Fatal: $message', _ansiRed);
    stderr.writeln(message);
    exit(exitCode);
  }
}
