// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

/// Run [callback] with this Dart process having exclusive access to
/// [directory].
///
/// Note multiple isolates and isolate groups in the same Dart process share
/// locks, so these will be able to enter the exclusive section simultanously.
///
/// If provided, the [timeout] parameter determines how long to retry before
/// giving up. If the [timeout] is exceeded a [TimeoutException] is thrown.
///
/// If provided, the [logger] streams information on the the locking status, and
/// also streams error messages.
Future<T> runUnderDirectoryLock<T>(
  Directory directory,
  Future<T> Function() callback, {
  Duration? timeout,
  Logger? logger,
}) async {
  const lockFileName = '.lock';
  final lockFile = File.fromUri(directory.uri.resolve(lockFileName));
  return _runUnderFileLock(
    lockFile,
    callback,
    timeout: timeout,
    logger: logger,
  );
}

/// Run [callback] with this Dart process having exclusive access to [file].
///
/// Note multiple isolates and isolate groups in the same Dart process share
/// locks, so these will be able to enter the exclusive section simultanously.
///
/// If provided, the [timeout] parameter determines how long to retry before
/// giving up. If the [timeout] is exceeded a [TimeoutException] is thrown.
///
/// If provided, the [logger] streams information on the the locking status,
/// and also streams error messages.
Future<T> _runUnderFileLock<T>(
  File file,
  Future<T> Function() callback, {
  Duration? timeout,
  Logger? logger,
}) async {
  if (!await file.exists()) await file.create(recursive: true);
  final randomAccessFile = await file.open(mode: FileMode.write);
  var printed = false;
  final stopwatch = Stopwatch()..start();
  while (timeout == null || stopwatch.elapsed < timeout) {
    try {
      await randomAccessFile.lock(FileLock.exclusive);
      try {
        await randomAccessFile.writeString(
          'Last acquired by ${Platform.resolvedExecutable} '
          '(pid $pid) running ${Platform.script} on ${DateTime.now()}.',
        );
        return await callback();
      } finally {
        await randomAccessFile.unlock();
      }
    } on FileSystemException {
      if (!printed) {
        logger?.finer(
          'Waiting to be able to obtain lock of directory: ${file.path}.',
        );
        printed = true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  final message = 'Could not acquire the lock to ${file.path}.';
  logger?.severe(message);
  throw TimeoutException(message, timeout);
}
