// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:logging/logging.dart';
import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

const loadingUnitRoot = LoadingUnit('root');

void main() async {
  test('simple_link linking', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('simple_link/');

      final resourcesUri = tempUri.resolve('treeshaking_info.json');
      final recordings = Recordings(
        calls: {},
        instances: {},
      );
      await File.fromUri(
        resourcesUri,
      ).writeAsString(jsonEncode(recordings.toJson()));

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;

      Iterable<String> buildFiles() => Directory.fromUri(
        packageUri.resolve('.dart_tool/hooks_runner/'),
      ).listSync(recursive: true).map((file) => file.path);

      expect(buildFiles(), isNot(anyElement(endsWith('recorded_uses.json'))));

      await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        recordUse: RecordUseConfig(
          file: resourcesUri,
          entryPoints: [Uri.file('bin/simple_link.dart')],
          compiler: 'dart_aot_compiler_v1',
        ),
        buildAssetTypes: [.data],
      );
      expect(buildFiles(), anyElement(endsWith('recorded_uses.json')));
    });
  });

  test('record_use_filtering linking', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('pirate_adventure/');

      final resourcesUri = tempUri.resolve('treeshaking_info.json');
      await File.fromUri(
        resourcesUri,
      ).writeAsString(jsonEncode(_pirateAdventureRecordings.toJson()));

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;

      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        recordUse: RecordUseConfig(
          file: resourcesUri,
          entryPoints: [Uri.file('bin/pirate_adventure.dart')],
          compiler: 'dart_aot_compiler_v1',
        ),
        buildAssetTypes: [.data],
      )).success;

      // Verify outputs
      final pirateSpeakAssets = linkResult.encodedAssets
          .where((a) => a.asDataAsset.package == 'pirate_speak')
          .toList();
      expect(pirateSpeakAssets, hasLength(1));
      final pirateSpeakFile = pirateSpeakAssets.first.asDataAsset.file;
      final pirateSpeakContent = jsonDecode(
        await File.fromUri(pirateSpeakFile).readAsString(),
      );
      expect(
        pirateSpeakContent,
        equals({'Hello': 'Ahoy', 'Money': 'Doubloons'}),
      );

      final pirateTechAssets = linkResult.encodedAssets
          .where((a) => a.asDataAsset.package == 'pirate_technology')
          .toList();
      expect(pirateTechAssets, hasLength(1));
      final pirateTechFile = pirateTechAssets.first.asDataAsset.file;
      final pirateTechContent = jsonDecode(
        await File.fromUri(pirateTechFile).readAsString(),
      );
      expect(
        pirateTechContent,
        equals({
          'Cannon': {'range': 100, 'damage': 50},
        }),
      );
    });
  });

  test('record_use_filtering caching', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('pirate_adventure/');

      final resourcesUri = tempUri.resolve('treeshaking_info.json');
      await File.fromUri(
        resourcesUri,
      ).writeAsString(jsonEncode(_pirateAdventureRecordings.toJson()));

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;

      final logMessages = <String>[];
      Future<void> runLink(Uri file) async {
        logMessages.clear();
        await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          recordUse: RecordUseConfig(
            file: file,
            entryPoints: [Uri.file('bin/pirate_adventure.dart')],
            compiler: 'dart_aot_compiler_v1',
          ),
          buildAssetTypes: [.data],
          capturedLogs: logMessages,
        );
      }

      // Initial run: should run hooks.
      await runLink(resourcesUri);
      expect(
        logMessages.join('\n'),
        stringContainsInOrder(['pirate_speak', 'hook.dill']),
      );

      // Second run: should be cached.
      await runLink(resourcesUri);
      expect(
        logMessages.join('\n'),
        contains('Skipping link for pirate_speak'),
      );

      // Change file path but keep contents: should be cached.
      final resourcesUriDifferentPath = tempUri.resolve(
        'treeshaking_info_different_path.json',
      );
      await File.fromUri(resourcesUriDifferentPath).writeAsString(
        jsonEncode(_pirateAdventureRecordings.toJson()),
      );
      await runLink(resourcesUriDifferentPath);
      expect(
        logMessages.join('\n'),
        contains('Skipping link for pirate_speak'),
      );

      // Change irrelevant recorded uses (unrelated package): should be cached.
      final irrelevantRecordings = Recordings(
        calls: {
          ..._pirateAdventureRecordings.calls,
          const Method(
            'dummy',
            Library('package:dummy/dummy.dart'),
          ): [
            const CallWithArguments(
              loadingUnit: loadingUnitRoot,
              positionalArguments: [],
              namedArguments: {},
            ),
          ],
        },
        instances: {},
      );
      await File.fromUri(resourcesUri).writeAsString(
        jsonEncode(irrelevantRecordings.toJson()),
      );
      await runLink(resourcesUri);
      expect(
        logMessages.join('\n'),
        contains('Skipping link for pirate_speak'),
      );

      // Change relevant recorded uses (this package): should re-run hooks.
      final newRecordings = Recordings(
        calls: {
          ..._pirateAdventureRecordings.calls,
          const Method(
            'dummy',
            Library('package:pirate_speak/src/definitions.dart'),
          ): [
            const CallWithArguments(
              loadingUnit: loadingUnitRoot,
              positionalArguments: [],
              namedArguments: {},
            ),
          ],
        },
        instances: {},
      );
      await File.fromUri(
        resourcesUri,
      ).writeAsString(jsonEncode(newRecordings.toJson()));

      await runLink(resourcesUri);
      expect(
        logMessages.join('\n'),
        stringContainsInOrder(['pirate_speak', 'hook.dill']),
      );

      // Run again: should be cached again.
      await runLink(resourcesUri);
      expect(
        logMessages.join('\n'),
        contains('Skipping link for pirate_speak'),
      );
    });
  });

  test(
    'concurrent link invocations with recorded_uses',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('pirate_adventure/');

        // Write each filtered output to a content-specific file so concurrent
        // link runs with different recordings do not overwrite each other's
        // emitted asset file in the shared output directory before
        // verification.
        final pirateSpeakLinkHook = File.fromUri(
          tempUri.resolve('pirate_speak/hook/link.dart'),
        );
        await pirateSpeakLinkHook.writeAsString(
          (await pirateSpeakLinkHook.readAsString()).replaceFirst(
            "'filtered_translations.json'",
            r"'filtered_translations_${content.keys.join('_')}.json'",
          ),
        );

        await runPubGet(workingDirectory: packageUri, logger: logger);

        final buildResult = (await buildDataAssets(
          packageUri,
          linkingEnabled: true,
        )).success;

        Future<(LinkResult, List<LogRecord>)> runLink(Uri file) async {
          final records = <LogRecord>[];
          final callLogger = createCapturingLogger([])
            ..onRecord.listen(records.add);
          final result = await link(
            packageUri,
            callLogger,
            dartExecutable,
            buildResult: buildResult,
            recordUse: RecordUseConfig(
              file: file,
              entryPoints: [Uri.file('bin/pirate_adventure.dart')],
              compiler: 'dart_aot_compiler_v1',
            ),
            buildAssetTypes: [.data],
          );
          expect(result.isSuccess, isTrue);
          return (result.success, records);
        }

        Future<Object?> readPirateSpeakAsset(LinkResult linkResult) async {
          final assets = linkResult.encodedAssets
              .where((a) => a.asDataAsset.package == 'pirate_speak')
              .toList();
          expect(assets, hasLength(1));
          return jsonDecode(
            await File.fromUri(assets.first.asDataAsset.file).readAsString(),
          );
        }

        await IOOverrides.runWithIOOverrides(() async {
          // (a) Two concurrent link() calls with identical RecordUseConfig and
          // recordings.
          final resourcesIdenticalUri = tempUri.resolve(
            'treeshaking_same.json',
          );
          await File.fromUri(
            resourcesIdenticalUri,
          ).writeAsString(jsonEncode(_pirateAdventureRecordings.toJson()));

          final [
            (identicalResult1, identicalRecords1),
            (identicalResult2, identicalRecords2),
          ] = await Future.wait([
            runLink(resourcesIdenticalUri),
            runLink(resourcesIdenticalUri),
          ]);

          expect(
            identicalRecords1.where((r) => r.level >= Level.SEVERE),
            isEmpty,
          );
          expect(
            identicalRecords2.where((r) => r.level >= Level.SEVERE),
            isEmpty,
          );
          expect(
            await readPirateSpeakAsset(identicalResult1),
            equals({'Hello': 'Ahoy', 'Money': 'Doubloons'}),
          );
          expect(
            await readPirateSpeakAsset(identicalResult2),
            equals({'Hello': 'Ahoy', 'Money': 'Doubloons'}),
          );

          // (b) Two concurrent link() calls sharing the same RecordUseConfig
          // (entryPoints and compiler) but pointing RecordUseConfig.file at two
          // different source recording files (e.g. concurrent `dart build cli`
          // runs with different `-D` defines).
          final recordingsHelloOnly = Recordings(
            calls: {
              const Method(
                'pirateSpeak',
                Library('package:pirate_speak/src/definitions.dart'),
              ): [
                const CallWithArguments(
                  loadingUnit: loadingUnitRoot,
                  positionalArguments: [StringConstant('Hello')],
                  namedArguments: {},
                ),
              ],
              const Method(
                'useCannon',
                Library('package:pirate_technology/src/definitions.dart'),
              ): [
                const CallWithArguments(
                  loadingUnit: loadingUnitRoot,
                  positionalArguments: [],
                  namedArguments: {},
                ),
              ],
            },
            instances: {},
          );
          final recordingsMoneyOnly = Recordings(
            calls: {
              const Method(
                'pirateSpeak',
                Library('package:pirate_speak/src/definitions.dart'),
              ): [
                const CallWithArguments(
                  loadingUnit: loadingUnitRoot,
                  positionalArguments: [StringConstant('Money')],
                  namedArguments: {},
                ),
              ],
              const Method(
                'useCannon',
                Library('package:pirate_technology/src/definitions.dart'),
              ): [
                const CallWithArguments(
                  loadingUnit: loadingUnitRoot,
                  positionalArguments: [],
                  namedArguments: {},
                ),
              ],
            },
            instances: {},
          );

          final resourcesHelloUri = tempUri.resolve('treeshaking_hello.json');
          final resourcesMoneyUri = tempUri.resolve('treeshaking_money.json');
          await File.fromUri(
            resourcesHelloUri,
          ).writeAsString(jsonEncode(recordingsHelloOnly.toJson()));
          await File.fromUri(
            resourcesMoneyUri,
          ).writeAsString(jsonEncode(recordingsMoneyOnly.toJson()));

          final [
            (helloResult, helloRecords),
            (moneyResult, moneyRecords),
          ] = await Future.wait([
            runLink(resourcesHelloUri),
            runLink(resourcesMoneyUri),
          ]);

          expect(helloRecords.where((r) => r.level >= Level.SEVERE), isEmpty);
          expect(moneyRecords.where((r) => r.level >= Level.SEVERE), isEmpty);
          expect(
            await readPirateSpeakAsset(helloResult),
            equals({'Hello': 'Ahoy'}),
          );
          expect(
            await readPirateSpeakAsset(moneyResult),
            equals({'Money': 'Doubloons'}),
          );
        }, _InProcessLockingIOOverrides());
      });
    },
  );
}

/// Expected result of the compiler when running from pirate_adventure
/// bin/pirate_adventure.dart.
final _pirateAdventureRecordings = Recordings(
  calls: {
    const Method(
      'pirateSpeak',
      Library('package:pirate_speak/src/definitions.dart'),
    ): [
      const CallWithArguments(
        loadingUnit: loadingUnitRoot,
        positionalArguments: [StringConstant('Hello')],
        namedArguments: {},
      ),
      const CallWithArguments(
        loadingUnit: loadingUnitRoot,
        positionalArguments: [StringConstant('Money')],
        namedArguments: {},
      ),
    ],
    const Method(
      'useCannon',
      Library('package:pirate_technology/src/definitions.dart'),
    ): [
      const CallWithArguments(
        loadingUnit: loadingUnitRoot,
        positionalArguments: [],
        namedArguments: {},
      ),
    ],
  },
  instances: {},
);

/// Enforces exclusive `.lock` file acquisition across concurrent calls in the
/// same OS process (since POSIX `fcntl` file locks are per-process rather than
/// per-file-descriptor).
final class _InProcessLockingIOOverrides extends IOOverrides {
  final Set<String> _lockedPaths = {};

  @override
  File createFile(String path) {
    final file = super.createFile(path);
    if (path.endsWith('.lock')) {
      return _InProcessLockingFile(this, file);
    }
    return file;
  }
}

class _InProcessLockingFile implements File {
  _InProcessLockingFile(this._overrides, this._delegate);

  final _InProcessLockingIOOverrides _overrides;
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
      _InProcessLockingRandomAccessFile(
        _overrides,
        path,
        await _delegate.open(mode: mode),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InProcessLockingRandomAccessFile implements RandomAccessFile {
  _InProcessLockingRandomAccessFile(
    this._overrides,
    this._path,
    this._delegate,
  );

  final _InProcessLockingIOOverrides _overrides;
  final String _path;
  final RandomAccessFile _delegate;
  bool _holdsLock = false;

  @override
  Future<RandomAccessFile> lock([
    FileLock mode = FileLock.exclusive,
    int start = 0,
    int end = -1,
  ]) async {
    if (!_overrides._lockedPaths.add(_path)) {
      throw FileSystemException('lock failed', _path);
    }
    _holdsLock = true;
    await _delegate.lock(mode, start, end);
    return this;
  }

  @override
  Future<RandomAccessFile> unlock([int start = 0, int end = -1]) async {
    if (_holdsLock) {
      _overrides._lockedPaths.remove(_path);
      _holdsLock = false;
    }
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
    if (_holdsLock) {
      _overrides._lockedPaths.remove(_path);
      _holdsLock = false;
    }
    await _delegate.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
