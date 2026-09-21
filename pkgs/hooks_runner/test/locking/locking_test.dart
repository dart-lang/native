// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file/local.dart';
import 'package:hooks_runner/src/locking/locking.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

import '../helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  final packageUri = findPackageRoot('hooks_runner');

  test('Concurrent invocations', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      Future<ProcessResult> runInProcess() async {
        final result = await Process.run(dartExecutable.toFilePath(), [
          packageUri
              .resolve('test/locking/locking_test_helper.dart')
              .toFilePath(),
          tempUri.toFilePath(),
        ]);
        printOnFailure(result.stderr.toString());
        printOnFailure(result.stdout.toString());
        expect(result.exitCode, 0);
        return result;
      }

      await Future.wait([runInProcess(), runInProcess(), runInProcess()]);
    });
  });

  File? findLockFile(Uri tempUri) {
    final lockFile = File.fromUri(tempUri.resolve('.lock'));
    if (lockFile.existsSync()) {
      final lockFileContents = lockFile.readAsStringSync();
      if (lockFileContents.isNotEmpty) {
        // The process might have been killed in between creating the lock
        // file and writing to it.
        expect(lockFileContents, stringContainsInOrder(['Last acquired by']));
      }
      return lockFile;
    }
    return null;
  }

  test('Terminations unlock', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      Future<int> runProcess({Duration? killAfter}) async {
        final process = await Process.start(dartExecutable.toFilePath(), [
          packageUri
              .resolve('test/locking/locking_test_helper.dart')
              .toFilePath(),
          tempUri.toFilePath(),
        ]);

        final stdoutSub = process.stdout
            .transform(systemEncoding.decoder)
            .transform(const LineSplitter())
            .listen(logger.fine);
        final stderrSub = process.stderr
            .transform(systemEncoding.decoder)
            .transform(const LineSplitter())
            .listen(logger.severe);

        Timer? timer;
        if (killAfter != null) {
          timer = Timer(killAfter, () async {
            printOnFailure('killing process');
            process.kill();
          });
        }
        final (exitCode, _, _) = await (
          process.exitCode,
          stdoutSub.asFuture<void>(),
          stderrSub.asFuture<void>(),
        ).wait;
        if (timer != null) {
          timer.cancel();
        }

        return exitCode;
      }

      // Kill process before it finishes. To check lock is properly released.
      var milliseconds = 100;
      while (findLockFile(tempUri) == null) {
        final result = await runProcess(
          killAfter: Duration(milliseconds: milliseconds),
        );
        expect(result, isNot(0));
        milliseconds = max((milliseconds * 1.1).round(), milliseconds + 100);
      }
      expect(findLockFile(tempUri), isNotNull);

      final result2 = await runProcess();
      expect(result2, 0);
    });
  });

  test('Timeout exits process', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      Future<void> runProcess({
        Duration? timeout,
        bool expectTimeOut = false,
      }) async {
        final process = await Process.start(dartExecutable.toFilePath(), [
          packageUri
              .resolve('test/locking/locking_test_helper.dart')
              .toFilePath(),
          tempUri.toFilePath(),
          if (timeout != null) timeout.inMilliseconds.toString(),
        ]);

        final stdoutSub = process.stdout
            .transform(systemEncoding.decoder)
            .transform(const LineSplitter())
            .listen(logger.fine);
        final stderrSub = process.stderr
            .transform(systemEncoding.decoder)
            .transform(const LineSplitter())
            .listen(logger.severe);

        final (exitCode, _, _) = await (
          process.exitCode,
          stdoutSub.asFuture<void>(),
          stderrSub.asFuture<void>(),
        ).wait;

        if (expectTimeOut) {
          expect(exitCode, isNot(0));
        } else {
          expect(exitCode, 0);
        }
      }

      await runProcess();

      final lockFile = findLockFile(tempUri);
      expect(lockFile, isNotNull);
      lockFile!;

      final s = Stopwatch();
      s.start();
      await runProcess();
      s.stop();
      final oneTimeRun = s.elapsed;
      printOnFailure('oneTimeRun: $oneTimeRun');
      // Some arbitrary time that the inner process will wait to try to grab the
      // lock. At least a multiple of the magic constant of 50 milliseconds.
      const helperProcessTimeout = Duration(milliseconds: 200);
      printOnFailure('helperProcessTimeout: $helperProcessTimeout');
      // In a normal test run, the timer should always be cancelled. But pass
      // some reasonable upper bound.
      final timerTimeout = oneTimeRun * 10;
      printOnFailure('timerTimeout: $timerTimeout');

      final randomAccessFile = await lockFile.open(mode: .write);
      final lock = await randomAccessFile.lock(FileLock.exclusive);
      var helperCompletedFirst = false;
      var timeoutCompletedFirst = false;
      final timer = Timer(timerTimeout, () async {
        printOnFailure('${DateTime.now()}: Timer expired.');
        if (!helperCompletedFirst) {
          printOnFailure('${DateTime.now()}: timeoutCompletedFirst');
          timeoutCompletedFirst = true;
        }
        await lock.unlock();
      });
      await runProcess(timeout: helperProcessTimeout, expectTimeOut: true).then(
        (v) async {
          printOnFailure('${DateTime.now()}: Helper exited.');
          if (!timeoutCompletedFirst) {
            printOnFailure('${DateTime.now()}: timeoutCompletedFirst');
            helperCompletedFirst = true;
          }
          timer.cancel();
        },
      );
      expect(helperCompletedFirst, isTrue);
      expect(timeoutCompletedFirst, isFalse);
    });
  });

  group('IOOverrides locking tests', () {
    const contentionCodesByOs = <String, List<(String, int)>>{
      'linux': [('Linux EAGAIN', 11), ('POSIX EACCES', 13)],
      'macos': [('macOS EAGAIN', 35), ('POSIX EACCES', 13)],
      'windows': [
        ('Windows ERROR_SHARING_VIOLATION', 32),
        ('Windows ERROR_LOCK_VIOLATION', 33),
      ],
    };
    final currentOsContentionCodes =
        contentionCodesByOs[Platform.operatingSystem]!;
    final currentOsContentionCodeNumbers = currentOsContentionCodes
        .map((e) => e.$2)
        .toSet();

    for (final (String name, int errorCode) in <(String, int)>[
      ('macOS ENOTSUP', 45),
      ('macOS ENOLCK', 77),
      ('macOS ENOSYS', 78),
      ('POSIX EINVAL', 22),
      ('Linux ENOTSUP', 95),
      ('Linux ENOLCK', 37),
      ('Linux ENOSYS', 38),
      ('Windows ERROR_NOT_SUPPORTED', 50),
      for (final entry in contentionCodesByOs.entries)
        if (entry.key != Platform.operatingSystem)
          for (final code in entry.value)
            if (!currentOsContentionCodeNumbers.contains(code.$2)) code,
    ]) {
      test(
        'fails eagerly on FileSystemException with $name ($errorCode)',
        () async {
          await inTempDir((tempUri) async {
            final overrides = _LockTestingIOOverrides()
              ..errorToThrowOnLock = FileSystemException(
                'lock failed',
                tempUri.resolve('.lock').toFilePath(),
                OSError('Unsupported', errorCode),
              );
            final capturedMessages = <String>[];
            final testLogger = createCapturingLogger(capturedMessages);

            await IOOverrides.runWithIOOverrides(() async {
              await expectLater(
                () => runUnderDirectoryLock<void>(
                  const LocalFileSystem(),
                  tempUri,
                  () async {},
                  logger: testLogger,
                ),
                throwsA(
                  isA<FileSystemException>().having(
                    (e) => e.message,
                    'message',
                    contains(
                      'Running hooks_runner on a project on a file system '
                      'where process locks are not supported is not supported. '
                      'Please move your project to a different location.',
                    ),
                  ),
                ),
              );
            }, overrides);

            expect(overrides.lockAttempts, 1);
            expect(overrides.lockCount, 0);
            expect(overrides.unlockCount, 0);
            expect(overrides.closeCount, 1);
            expect(
              capturedMessages.join('\n'),
              contains(
                'Running hooks_runner on a project on a file system where '
                'process locks are not supported is not supported. '
                'Please move your project to a different location.',
              ),
            );
            expect(
              capturedMessages.join('\n'),
              isNot(contains('Waiting to be able to obtain lock')),
            );
          });
        },
      );
    }

    for (final (String name, int? errorCode) in <(String, int?)>[
      ('null OSError', null),
      ...currentOsContentionCodes,
    ]) {
      test('retries on lock contention with $name and succeeds', () async {
        await inTempDir((tempUri) async {
          final overrides = _LockTestingIOOverrides()
            ..retryAttemptsBeforeSuccess = 1
            ..errorToThrowOnLock = FileSystemException(
              'lock failed',
              tempUri.resolve('.lock').toFilePath(),
              errorCode == null ? null : OSError('Contention', errorCode),
            );
          final capturedMessages = <String>[];
          final testLogger = createCapturingLogger(capturedMessages);

          final result = await IOOverrides.runWithIOOverrides(
            () => runUnderDirectoryLock<String>(
              const LocalFileSystem(),
              tempUri,
              () async => 'success',
              logger: testLogger,
            ),
            overrides,
          );

          expect(result, 'success');
          expect(overrides.lockAttempts, 2);
          expect(overrides.lockCount, 1);
          expect(overrides.unlockCount, 1);
          expect(overrides.closeCount, 1);
          expect(
            capturedMessages.join('\n'),
            contains('Waiting to be able to obtain lock of directory:'),
          );
        });
      });
    }

    test('times out when lock contention persists', () async {
      await inTempDir((tempUri) async {
        final overrides = _LockTestingIOOverrides()
          ..alwaysThrowOnLock = true
          ..errorToThrowOnLock = FileSystemException(
            'lock failed',
            tempUri.resolve('.lock').toFilePath(),
            OSError('Contention', currentOsContentionCodes.first.$2),
          );
        final capturedMessages = <String>[];
        final testLogger = createCapturingLogger(capturedMessages);

        await IOOverrides.runWithIOOverrides(() async {
          await expectLater(
            () => runUnderDirectoryLock<void>(
              const LocalFileSystem(),
              tempUri,
              () async {},
              timeout: const Duration(milliseconds: 60),
              logger: testLogger,
            ),
            throwsA(isA<TimeoutException>()),
          );
        }, overrides);

        expect(overrides.lockAttempts, greaterThanOrEqualTo(1));
        expect(overrides.lockCount, 0);
        expect(overrides.closeCount, 1);
        expect(
          capturedMessages.join('\n'),
          contains('Could not acquire the lock to'),
        );
      });
    });

    test('rethrows FileSystemException thrown by callback', () async {
      await inTempDir((tempUri) async {
        final overrides = _LockTestingIOOverrides();

        await IOOverrides.runWithIOOverrides(() async {
          await expectLater(
            () => runUnderDirectoryLock<void>(
              const LocalFileSystem(),
              tempUri,
              () async => throw const FileSystemException('callback error'),
              logger: logger,
            ),
            throwsA(
              isA<FileSystemException>().having(
                (e) => e.message,
                'message',
                'callback error',
              ),
            ),
          );
        }, overrides);

        expect(overrides.lockAttempts, 1);
        expect(overrides.lockCount, 1);
        expect(overrides.unlockCount, 1);
        expect(overrides.closeCount, 1);
      });
    });

    test('runUnderDirectoriesLock locks multiple directories', () async {
      await inTempDir((tempUri) async {
        final dir1 = tempUri.resolve('dir1/');
        final dir2 = tempUri.resolve('dir2/');
        final overrides = _LockTestingIOOverrides();

        final result = await IOOverrides.runWithIOOverrides(
          () => runUnderDirectoriesLock<int>(
            const LocalFileSystem(),
            [dir1, dir2],
            () async => 42,
            logger: logger,
          ),
          overrides,
        );

        expect(result, 42);
        expect(overrides.lockAttempts, 2);
        expect(overrides.lockCount, 2);
        expect(overrides.unlockCount, 2);
        expect(overrides.closeCount, 2);
      });
    });
  });
}

final class _LockTestingIOOverrides extends IOOverrides {
  int lockCount = 0;
  int unlockCount = 0;
  int closeCount = 0;
  int lockAttempts = 0;
  FileSystemException? errorToThrowOnLock;
  int retryAttemptsBeforeSuccess = 0;
  bool alwaysThrowOnLock = false;

  @override
  File createFile(String path) =>
      _LockTestingFile(this, super.createFile(path));
}

class _LockTestingFile implements File {
  _LockTestingFile(this._overrides, this._delegate);

  final _LockTestingIOOverrides _overrides;
  final File _delegate;

  @override
  String get path => _delegate.path;

  @override
  Uri get uri => _delegate.uri;

  @override
  Future<bool> exists() => _delegate.exists();

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) async {
    await _delegate.create(recursive: recursive, exclusive: exclusive);
    return this;
  }

  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) async =>
      _LockTestingRandomAccessFile(
        _overrides,
        await _delegate.open(mode: mode),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LockTestingRandomAccessFile implements RandomAccessFile {
  _LockTestingRandomAccessFile(this._overrides, this._delegate);

  final _LockTestingIOOverrides _overrides;
  final RandomAccessFile _delegate;

  @override
  Future<RandomAccessFile> lock([
    FileLock mode = FileLock.exclusive,
    int start = 0,
    int end = -1,
  ]) async {
    _overrides.lockAttempts++;
    final error = _overrides.errorToThrowOnLock;
    if (error != null) {
      if (_overrides.alwaysThrowOnLock) {
        throw error;
      }
      if (_overrides.retryAttemptsBeforeSuccess > 0) {
        _overrides.retryAttemptsBeforeSuccess--;
        throw error;
      } else if (_overrides.lockAttempts == 1) {
        throw error;
      }
    }
    await _delegate.lock(mode, start, end);
    _overrides.lockCount++;
    return this;
  }

  @override
  Future<RandomAccessFile> unlock([int start = 0, int end = -1]) async {
    _overrides.unlockCount++;
    await _delegate.unlock(start, end);
    return this;
  }

  @override
  Future<RandomAccessFile> writeString(
    String string, {
    Encoding encoding = utf8,
  }) async {
    await _delegate.writeString(string, encoding: encoding);
    return this;
  }

  @override
  Future<void> close() async {
    _overrides.closeCount++;
    await _delegate.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
