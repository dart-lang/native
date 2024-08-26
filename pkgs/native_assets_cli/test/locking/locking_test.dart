// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

import '../helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('Concurrent invocations', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      Future<ProcessResult> runInProcess() async {
        final result = await Process.run(
          dartExecutable.toFilePath(),
          [
            packageUri
                .resolve('test/locking/locking_test_helper.dart')
                .toFilePath(),
            tempUri.toFilePath(),
          ],
        );
        printOnFailure(result.stderr.toString());
        printOnFailure(result.stdout.toString());
        expect(result.exitCode, 0);
        return result;
      }

      await Future.wait([
        runInProcess(),
        runInProcess(),
        runInProcess(),
      ]);
    });
  });

  File? findLockFile(Uri tempUri) {
    final lockFile = File.fromUri(tempUri.resolve('.lock'));
    if (lockFile.existsSync()) {
      final lockFileContents = lockFile.readAsStringSync();
      if (lockFileContents.isNotEmpty) {
        // The process might have been killed in between creating the lock
        // file and writing to it.
        expect(
          lockFileContents,
          stringContainsInOrder(['Last acquired by']),
        );
      }
      return lockFile;
    }
    return null;
  }

  test('Terminations unlock', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      Future<int> runProcess({
        Duration? killAfter,
      }) async {
        final process = await Process.start(
          dartExecutable.toFilePath(),
          [
            packageUri
                .resolve('test/locking/locking_test_helper.dart')
                .toFilePath(),
            tempUri.toFilePath(),
          ],
        );
        final stdoutSub = process.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(logger.fine);
        final stderrSub = process.stderr
            .transform(utf8.decoder)
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
          stderrSub.asFuture<void>()
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
      Future<ProcessResult> runProcess({
        Duration? timeout,
        bool expectTimeOut = false,
      }) async {
        final result = await Process.run(
          dartExecutable.toFilePath(),
          [
            packageUri
                .resolve('test/locking/locking_test_helper.dart')
                .toFilePath(),
            tempUri.toFilePath(),
            if (timeout != null) timeout.inMilliseconds.toString(),
          ],
        );
        if (expectTimeOut) {
          expect(result.exitCode, isNot(0));
        } else {
          expect(result.exitCode, 0);
        }

        return result;
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
      final helperProcessTimeout = Duration(
        milliseconds: min(
          oneTimeRun.inMilliseconds * 2,
          oneTimeRun.inMilliseconds + 1000,
        ),
      );
      printOnFailure('helperProcessTimeout: $helperProcessTimeout');
      final timerTimeout = Duration(
        milliseconds: min(
          helperProcessTimeout.inMilliseconds * 2,
          helperProcessTimeout.inMilliseconds + 1000,
        ),
      );
      printOnFailure('timerTimeout: $timerTimeout');

      final randomAccessFile = await lockFile.open(mode: FileMode.write);
      final lock = await randomAccessFile.lock(FileLock.exclusive);
      var helperCompletedFirst = false;
      var timeoutCompletedFirst = false;
      final timer = Timer(timerTimeout, () async {
        printOnFailure('Timer expired.');
        if (!helperCompletedFirst) {
          printOnFailure('timeoutCompletedFirst');
          timeoutCompletedFirst = true;
        }
        await lock.unlock();
      });
      await runProcess(
        timeout: helperProcessTimeout,
        expectTimeOut: true,
      ).then((v) async {
        printOnFailure('Helper exited.');
        if (!timeoutCompletedFirst) {
          printOnFailure('timeoutCompletedFirst');
          helperCompletedFirst = true;
        }
        timer.cancel();
      });
      expect(helperCompletedFirst, isTrue);
      expect(timeoutCompletedFirst, isFalse);
    });
  });
}
