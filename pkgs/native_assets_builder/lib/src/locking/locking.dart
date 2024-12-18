// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Platform, pid;
import 'package:file/file.dart';

import 'package:logging/logging.dart';

Future<T> runUnderDirectoriesLock<T>(
  FileSystem fileSystem,
  List<Directory> directories,
  Future<T> Function() callback, {
  Duration? timeout,
  Logger? logger,
}) async {
  if (directories.isEmpty) {
    return await callback();
  }
  return await runUnderDirectoryLock(
    fileSystem,
    directories.first,
    () => runUnderDirectoriesLock<T>(
      fileSystem,
      directories.skip(1).toList(),
      callback,
      timeout: timeout,
      logger: logger,
    ),
    timeout: timeout,
    logger: logger,
  );
}

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
  FileSystem fileSystem,
  Directory directory,
  Future<T> Function() callback, {
  Duration? timeout,
  Logger? logger,
}) async {
  const lockFileName = '.lock';
  final lockFile = _fileInDir(fileSystem, directory, lockFileName);
  return _runUnderFileLock(
    lockFile,
    callback,
    timeout: timeout,
    logger: logger,
  );
}

File _fileInDir(FileSystem fileSystem, Directory path, String filename) {
  final dirPath = path.path;
  var separator = Platform.pathSeparator;
  if (dirPath.endsWith(separator)) separator = '';
  return fileSystem.file('$dirPath$separator$filename');
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
      // Don't busy wait, give the CPU some rest.
      // Magic constant taken from flutter_tools for startup lock.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  final message = 'Could not acquire the lock to ${file.path}.';
  logger?.severe(message);
  throw TimeoutException(message, timeout);
}
