// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// coverage:ignore-file

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

Logger log = () {
  final jnigenLogger = Logger('jnigen');
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((r) {
    var message = '(${r.loggerName}) ${r.level.name}: ${r.message}';
    if ((r.level == Level.SHOUT || r.level == Level.SEVERE)) {
      message = _colorize(message, _ansiRed);
    } else if (r.level == Level.WARNING) {
      message = _colorize(message, _ansiYellow);
    }
    stderr.writeln(message);
  });
  return jnigenLogger;
}();

/// Set logging level to [level].
void setLoggingLevel(Level level) {
  /// This initializes `log` as a side effect, so that level setting we apply
  /// is always the last one applied.
  log.fine('Set log level: $level');
  Logger.root.level = level;
}

/// Prints [message] without logging information.
///
/// Primarily used in printing output of failed commands.
void printError(Object? message) {
  stderr.writeln(_colorize(message.toString(), _ansiRed));
}

extension FatalErrors on Logger {
  Never fatal(Object? message, {int exitCode = 1}) {
    message = _colorize('Fatal: $message', _ansiRed);
    stderr.writeln(message);
    return exit(exitCode);
  }
}
