// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';

/// Creates a default logger that logs to stdout and stderr.
Logger createDefaultLogger([Level level = Level.INFO]) {
  final logger = Logger.detached('FFIgen');
  logger.level = level;
  logger.onRecord.listen((record) {
    final levelStr = '[${record.level.name}]'.padRight(9);
    final log = '$levelStr: ${record.message}';
    if (record.level >= Level.WARNING) {
      stderr.writeln(log);
    } else {
      stdout.writeln(log);
    }
    if (record.error != null) {
      stderr.writeln(record.error);
    }
    if (record.stackTrace != null) {
      stderr.writeln(record.stackTrace);
    }
  });
  return logger;
}
