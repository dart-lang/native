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

/// Format [DateTime] for use in filename
String _formatTime(DateTime now) {
  return '${now.year}-${now.month}-${now.day}-'
      '${now.hour}.${now.minute}.${now.second}';
}

// We need to respect logging level for console but log everything to file.
// Hierarchical logging is convoluted. I'm just keeping track of log level.
var _logLevel = Level.INFO;

final _logDirUri = Directory.current.uri.resolve('.dart_tool/jnigen/logs/');

final _logDir = () {
  final dir = Directory.fromUri(_logDirUri);
  dir.createSync(recursive: true);
  return dir;
}();

Uri _getDefaultLogFileUri() =>
    _logDir.uri.resolve('jnigen-${_formatTime(DateTime.now())}.log');

IOSink? _logStream;

/// Enable saving the logs to a file.
///
/// This is only meant to be called from an application entry point such as
/// `main`.
void enableLoggingToFile() {
  _deleteOldLogFiles();
  if (_logStream != null) {
    throw StateError('Log file is already set');
  }
  _logStream = File.fromUri(_getDefaultLogFileUri()).openWrite();
}

// Maximum number of log files to keep.
const _maxLogFiles = 5;

/// Delete log files except most recent [_maxLogFiles] files.
void _deleteOldLogFiles() {
  final logFiles = _logDir.listSync().map((f) => File(f.path)).toList();
  // sort in descending order of last modified time.
  logFiles
      .sort((f1, f2) => f2.lastModifiedSync().compareTo(f1.lastModifiedSync()));
  final toDelete = logFiles.length < _maxLogFiles
      ? const <File>[]
      : logFiles.sublist(_maxLogFiles - 1);
  for (final oldLogFile in toDelete) {
    oldLogFile.deleteSync();
  }
}

Logger log = () {
  // initialize the logger.
  final jnigenLogger = Logger('jnigen');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((r) {
    // Write to file regardless of level.
    _logStream?.writeln('${r.level} ${r.time}: ${r.message}');
    // write to console only if level is above configured level.
    if (r.level < _logLevel) {
      return;
    }
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
  log.fine('Set log level: $level');
  _logLevel = level;
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

extension WriteToFile on Logger {
  void writeToFile(Object? data) {
    _logStream?.writeln(data);
  }

  void writeSectionToFile(String? sectionName, Object? data) {
    _logStream?.writeln('==== Begin $sectionName ====');
    _logStream?.writeln(data);
    _logStream?.writeln('==== End $sectionName ====');
  }
}
