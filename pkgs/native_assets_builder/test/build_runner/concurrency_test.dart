// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:native_assets_builder/src/utils/run_process.dart'
    show RunProcessResult;
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('Concurrent invocations', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      Future<RunProcessResult> runBuildInProcess() async {
        final result = await runProcess(
          executable: dartExecutable,
          arguments: [
            pkgNativeAssetsBuilderUri
                .resolve('test/build_runner/concurrency_test_helper.dart')
                .toFilePath(),
            packageUri.toFilePath(),
          ],
          workingDirectory: packageUri,
          logger: logger,
        );
        expect(result.exitCode, 0);
        return result;
      }

      // Simulate running `dart run` concurrently in 3 different terminals.
      await Future.wait([
        runBuildInProcess(),
        runBuildInProcess(),
        runBuildInProcess(),
      ]);
    });
  });

  File? findLockFile(Uri packageUri) {
    final dir = Directory.fromUri(
        packageUri.resolve('.dart_tool/native_assets_builder/'));
    if (!dir.existsSync()) {
      // Too quick, dir doesn't exist yet.
      return null;
    }
    for (final entity in dir.listSync().whereType<Directory>()) {
      final lockFile = File.fromUri(entity.uri.resolve('.lock'));
      if (lockFile.existsSync()) {
        final lockFileContents = lockFile.readAsStringSync();
        expect(lockFileContents, stringContainsInOrder(['Last acquired by']));
        return lockFile;
      }
    }
    return null;
  }

  test('Terminations unlock', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      Future<int> runBuildInProcess({Duration? killAfter}) async {
        final process = await Process.start(
          dartExecutable.toFilePath(),
          [
            pkgNativeAssetsBuilderUri
                .resolve('test/build_runner/concurrency_test_helper.dart')
                .toFilePath(),
            packageUri.toFilePath(),
          ],
          workingDirectory: packageUri.toFilePath(),
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
          timer = Timer(killAfter, process.kill);
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

      // Simulate hitting ctrl+c on `dart` and `flutter` commands at different
      // time intervals.
      var milliseconds = 200;
      while (findLockFile(packageUri) == null) {
        final result = await runBuildInProcess(
          killAfter: Duration(milliseconds: milliseconds),
        );
        expect(result, isNot(0));
        milliseconds = max((milliseconds * 1.2).round(), milliseconds + 200);
      }
      expect(findLockFile(packageUri), isNotNull);

      final result2 = await runBuildInProcess();
      expect(result2, 0);
    });
  });

  test('Timeout exits process', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      Future<RunProcessResult> runBuildInProcess({
        Duration? timeout,
        bool expectTimeOut = false,
      }) async {
        final result = await runProcess(
          executable: dartExecutable,
          arguments: [
            pkgNativeAssetsBuilderUri
                .resolve('test/build_runner/concurrency_test_helper.dart')
                .toFilePath(),
            packageUri.toFilePath(),
            if (timeout != null) timeout.inSeconds.toString(),
          ],
          workingDirectory: packageUri,
          logger: logger,
        );
        if (expectTimeOut) {
          expect(result.exitCode, isNot(0));
        } else {
          expect(result.exitCode, 0);
        }

        return result;
      }

      await runBuildInProcess();

      final lockFile = findLockFile(packageUri);
      expect(lockFile, isNotNull);
      lockFile!;

      // Check how long a cached build takes.
      final s = Stopwatch();
      s.start();
      await runBuildInProcess();
      s.stop();
      final cachedInvocationDuration = s.elapsed;
      final singleHookTimeout = Duration(
        milliseconds: min(
          cachedInvocationDuration.inMilliseconds * 2,
          cachedInvocationDuration.inMilliseconds + 2000,
        ),
      );
      final helperTimeout = Duration(
        milliseconds: min(
          singleHookTimeout.inMilliseconds * 2,
          singleHookTimeout.inMilliseconds + 2000,
        ),
      );

      final randomAccessFile = await lockFile.open(mode: FileMode.write);
      final lock = await randomAccessFile.lock(FileLock.exclusive);
      var helperCompletedFirst = false;
      var timeoutCompletedFirst = false;
      final timer = Timer(helperTimeout, () async {
        printOnFailure('timer expired');
        if (!helperCompletedFirst) {
          timeoutCompletedFirst = true;
        }
        await lock.unlock();
      });
      await runBuildInProcess(
        timeout: singleHookTimeout,
        expectTimeOut: true,
      ).then((v) async {
        printOnFailure('helper exited');
        if (!timeoutCompletedFirst) {
          helperCompletedFirst = true;
        }
        timer.cancel();
      });
      expect(helperCompletedFirst, isTrue);
      expect(timeoutCompletedFirst, isFalse);
    });
  });
}
