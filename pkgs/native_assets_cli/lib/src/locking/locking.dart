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
  await _ensureLockfileExists(file, logger);

  var timedOut = false;
  Timer? timeoutTimer;
  if (timeout != null) {
    timeoutTimer = Timer(timeout, () {
      timedOut = true;
    });
  }

  final randomAccessFile = await file.open(mode: FileMode.write);
  var locked = false;
  var printed = false;
  while (!locked && !timedOut) {
    try {
      await randomAccessFile.lock(FileLock.exclusive);
      locked = true;
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

  if (locked) {
    timeoutTimer?.cancel();
    try {
      await file.writeAsString(
        'Last acquired by ${Platform.resolvedExecutable} '
        'running ${Platform.script} on ${DateTime.now()}.',
      );
      return await callback();
    } finally {
      await randomAccessFile.unlock();
    }
  }
  assert(timedOut);
  final message = 'Could not acquire the lock to ${file.path}.';
  logger?.severe(message);
  throw TimeoutException(message, timeout);
}

Future<void> _ensureLockfileExists(
  File file,
  Logger? logger,
) async {
  while (true) {
    try {
      if (!await file.exists()) {
        // This code could race with itself in another process.
        await file.create(recursive: true, exclusive: true);
      }
    } on FileSystemException catch (e) {
      // If it did race, log the exception and keep retrying.
      logger?.finer('Lock file creation raced, retrying. ${e.message}');
      continue;
    }
    return;
  }
}
