// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:file/local.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:hooks_runner/src/model/hook_result.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('break build', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      {
        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [.code],
        )).success;
        expect(result.encodedAssets.length, 1);
        await expectSymbols(
          asset: CodeAsset.fromEncoded(result.encodedAssets.single),
          symbols: ['add'],
        );
        expect(
          result.dependencies,
          contains(packageUri.resolve('src/native_add.c')),
        );
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_break_build/'),
        targetUri: packageUri,
      );

      {
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          createCapturingLogger(logMessages, level: Level.SEVERE),
          dartExecutable,
          buildAssetTypes: [BuildAssetType.code],
        );
        final fullLog = logMessages.join('\n');
        expect(result.isFailure, isTrue);
        expect(result.failure, HooksRunnerFailure.hookRun);
        expect(fullLog, contains('To reproduce run:'));
        final reproCommand = fullLog
            .split('\n')
            .skipWhile((l) => !l.contains('To reproduce run:'))
            .skip(1)
            .first;
        final reproResult = await Process.run(
          reproCommand,
          [],
          runInShell: true,
        );
        expect(reproResult.exitCode, isNot(0));
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_fix_build/'),
        targetUri: packageUri,
      );

      {
        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [.code],
        )).success;
        expect(result.encodedAssets.length, 1);
        await expectSymbols(
          asset: CodeAsset.fromEncoded(result.encodedAssets.single),
          symbols: ['add'],
        );
        expect(
          result.dependencies,
          contains(packageUri.resolve('src/native_add.c')),
        );
      }
    });
  });

  test(
    'do not build dependees after build failure',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('depend_on_fail_build_app/');

        await runPubGet(workingDirectory: packageUri, logger: logger);

        final logMessages = <String>[];
        await build(
          packageUri,
          logger,
          capturedLogs: logMessages,
          dartExecutable,
          buildAssetTypes: [.code],
        );
        Matcher stringContainsBuildHookCompilation(String packageName) =>
            stringContainsInOrder([
              'Running',
              'hook.dill',
              '$packageName${Platform.pathSeparator}'
                  'hook${Platform.pathSeparator}build.dart',
            ]);
        expect(
          logMessages.join('\n'),
          stringContainsBuildHookCompilation('fail_build'),
        );
        expect(
          logMessages.join('\n'),
          isNot(stringContainsBuildHookCompilation('depends_on_fail_build')),
        );
      });
    },
  );

  test('infra error', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('infra_failure/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final result = await build(
        packageUri,
        logger,
        dartExecutable,
        buildAssetTypes: [BuildAssetType.code],
      );
      expect(result.isFailure, isTrue);
      expect(result.failure, HooksRunnerFailure.infra);
    });
  });

  test(
    'directory lock timeout returns HooksRunnerFailure.infra',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('simple_link/');
        await runPubGet(workingDirectory: packageUri, logger: logger);

        final packageLayout = await PackageLayout.fromWorkingDirectory(
          const LocalFileSystem(),
          packageUri,
          'simple_link',
          includeDevDependencies: false,
        );
        final logMessages = <String>[];
        final testLogger = createCapturingLogger(
          logMessages,
          level: Level.SEVERE,
        );
        final runner = NativeAssetsBuildRunner(
          logger: testLogger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
          singleHookTimeout: const Duration(milliseconds: 60),
        );
        final overrides = _LockTestingIOOverrides(
          const FileSystemException('lock contention'),
        );

        await IOOverrides.runWithIOOverrides(() async {
          final buildResult = await runner.build(
            extensions: [DataAssetsExtension()],
            linkingEnabled: true,
          );
          expect(buildResult.isFailure, isTrue);
          expect(buildResult.failure, HooksRunnerFailure.infra);
          expect(
            logMessages.join('\n'),
            contains('Could not acquire the lock to'),
          );

          logMessages.clear();
          final linkResult = await runner.link(
            extensions: [DataAssetsExtension()],
            buildResult: HookResult(),
          );
          expect(linkResult.isFailure, isTrue);
          expect(linkResult.failure, HooksRunnerFailure.infra);
          expect(
            logMessages.join('\n'),
            contains('Could not acquire the lock to'),
          );
        }, overrides);
      });
    },
  );

  test(
    'unsupported file system lock returns HooksRunnerFailure.infra',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('simple_link/');
        await runPubGet(workingDirectory: packageUri, logger: logger);

        final packageLayout = await PackageLayout.fromWorkingDirectory(
          const LocalFileSystem(),
          packageUri,
          'simple_link',
          includeDevDependencies: false,
        );
        final logMessages = <String>[];
        final testLogger = createCapturingLogger(
          logMessages,
          level: Level.SEVERE,
        );
        final runner = NativeAssetsBuildRunner(
          logger: testLogger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
        );
        const posixEinval = 22;
        final overrides = _LockTestingIOOverrides(
          const FileSystemException(
            'lock failed',
            '',
            OSError('Invalid argument', posixEinval),
          ),
        );

        await IOOverrides.runWithIOOverrides(() async {
          final buildResult = await runner.build(
            extensions: [DataAssetsExtension()],
            linkingEnabled: true,
          );
          expect(buildResult.isFailure, isTrue);
          expect(buildResult.failure, HooksRunnerFailure.infra);
          expect(
            logMessages.join('\n'),
            contains(
              'The file system containing this project does not appear to '
              'support file locking',
            ),
          );

          logMessages.clear();
          final linkResult = await runner.link(
            extensions: [DataAssetsExtension()],
            buildResult: HookResult(),
          );
          expect(linkResult.isFailure, isTrue);
          expect(linkResult.failure, HooksRunnerFailure.infra);
          expect(
            logMessages.join('\n'),
            contains(
              'The file system containing this project does not appear to '
              'support file locking',
            ),
          );
        }, overrides);
      });
    },
  );
}

final class _LockTestingIOOverrides extends IOOverrides {
  _LockTestingIOOverrides(this.errorToThrowOnLock);

  final FileSystemException errorToThrowOnLock;

  @override
  File createFile(String path) => path.endsWith('.lock')
      ? _LockTestingFile(this, super.createFile(path))
      : super.createFile(path);
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
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  ]) async => throw _overrides.errorToThrowOnLock;

  @override
  Future<RandomAccessFile> unlock([int start = 0, int end = -1]) =>
      _delegate.unlock(start, end);

  @override
  Future<RandomAccessFile> writeString(
    String string, {
    Encoding encoding = utf8,
  }) => _delegate.writeString(string, encoding: encoding);

  @override
  Future<void> close() => _delegate.close();

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
