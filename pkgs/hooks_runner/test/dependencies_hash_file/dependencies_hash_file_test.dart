// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:file/local.dart';
import 'package:hooks_runner/src/dependencies_hash_file/dependencies_hash_file.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  final environment = Platform.environment;
  const fileSystem = LocalFileSystem();

  test('json format', () async {
    await inTempDir((tempUri) async {
      final now = DateTime.now();
      final hashes = FileSystemHashes(
        files: [
          FilesystemEntityHash(
            tempUri.resolve('foo.dll'),
            1337,
            size: 42,
            lastModified: now,
          ),
          FilesystemEntityHash(tempUri.resolve('bar.dll'), 4242),
        ],
      );
      final hashes2 = FileSystemHashes.fromJson(hashes.toJson());
      expect(hashes.files[0].path, equals(hashes2.files[0].path));
      expect(hashes.files[0].hash, equals(hashes2.files[0].hash));
      expect(hashes.files[0].size, equals(hashes2.files[0].size));
      expect(
        hashes.files[0].lastModified!.isAtSameMomentAs(
          hashes2.files[0].lastModified!,
        ),
        isTrue,
      );

      expect(hashes.files[1].path, equals(hashes2.files[1].path));
      expect(hashes.files[1].hash, equals(hashes2.files[1].hash));
      expect(hashes.files[1].size, isNull);
      expect(hashes.files[1].lastModified, isNull);
    });
  });

  test('skips content hash when size and lastModified match', () async {
    await inTempDir((tempUri) async {
      final tempFile = fileSystem.file(tempUri.resolve('foo.txt'));
      await tempFile.writeAsString('hello');

      final hashesFileUri = tempUri.resolve('hashes.json');
      final hashes = DependenciesHashFile(fileSystem, fileUri: hashesFileUri);

      await hashes.updateHashes(
        [tempFile.uri],
        (await tempFile.lastModified()).add(const Duration(minutes: 1)),
        environment,
      );

      // Fresh build: size and mtime match, so findOutdatedDependency returns
      // null.
      expect(await hashes.findOutdatedDependency(environment), isNull);

      // Even if the saved hash in the file were corrupt/dummy, matching size
      // and lastModified skips computing the content hash.
      final hashesFile = fileSystem.file(hashesFileUri);
      final dynamic initialDecoded = json.decode(
        hashesFile.readAsStringSync(),
      );
      final initialHashes = FileSystemHashes.fromJson(
        (initialDecoded as Map).cast<String, Object>(),
      );
      final fileStat = await tempFile.stat();
      final corruptedHashes = FileSystemHashes(
        files: [
          FilesystemEntityHash(
            tempFile.uri,
            99999999, // intentionally mismatched hash
            size: fileStat.size,
            lastModified: fileStat.modified,
          ),
        ],
        environment: initialHashes.environment,
      );
      await hashesFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(corruptedHashes.toJson()),
      );

      expect(await hashes.findOutdatedDependency(environment), isNull);

      // If mtime changes, content hashing runs and detects the mismatch.
      await tempFile.setLastModified(
        fileStat.modified.add(const Duration(seconds: 5)),
      );
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempFile.uri.toFilePath()),
      );
    });
  });

  test(
    'backward compatibility with hash files without size/lastModified',
    () async {
      await inTempDir((tempUri) async {
        final tempFile = fileSystem.file(tempUri.resolve('foo.txt'));
        await tempFile.writeAsString('hello');

        final hashesFileUri = tempUri.resolve('hashes.json');
        final hashes = DependenciesHashFile(fileSystem, fileUri: hashesFileUri);

        await hashes.updateHashes(
          [tempFile.uri],
          (await tempFile.lastModified()).add(const Duration(minutes: 1)),
          environment,
        );

        // Save without size and last_modified (legacy format).
        final hashesFile = fileSystem.file(hashesFileUri);
        final dynamic decodedJson = json.decode(hashesFile.readAsStringSync());
        final parsedHashes = FileSystemHashes.fromJson(
          (decodedJson as Map).cast<String, Object>(),
        );
        final oldFormatJson = <String, Object>{
          'file_system': <Object>[
            <String, Object>{
              'path': tempFile.path,
              'hash': parsedHashes.files.first.hash,
            },
          ],
          'environment': [
            for (final env in parsedHashes.environment) env.toJson(),
          ],
        };
        await hashesFile.writeAsString(json.encode(oldFormatJson));

        // Without size and lastModified, it falls back to hashing the file
        // content.
        expect(await hashes.findOutdatedDependency(environment), isNull);

        // If file content changes, it detects the change.
        await tempFile.writeAsString('world');
        expect(
          await hashes.findOutdatedDependency(environment),
          contains(tempFile.uri.toFilePath()),
        );
      });
    },
  );

  test('dependencies hash file', () async {
    await inTempDir((tempUri) async {
      final tempFile = fileSystem.file(tempUri.resolve('foo.txt'));
      final tempSubDir = fileSystem.directory(tempUri.resolve('subdir/'));
      final subFile = fileSystem.file(tempSubDir.uri.resolve('bar.txt'));

      final hashesFileUri = tempUri.resolve('hashes.json');
      final hashes = DependenciesHashFile(fileSystem, fileUri: hashesFileUri);

      Future<void> reset() async {
        await tempFile.create(recursive: true);
        await tempSubDir.create(recursive: true);
        await subFile.create(recursive: true);
        await tempFile.writeAsString('hello');
        await subFile.writeAsString('world');

        await hashes.updateHashes(
          [tempFile.uri, tempSubDir.uri],
          (await tempFile.lastModified()).add(const Duration(minutes: 1)),
          environment,
        );
      }

      await reset();

      // No changes
      expect(await hashes.findOutdatedDependency(environment), isNull);

      // Change file contents.
      await tempFile.writeAsString('asdf');
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempFile.uri.toFilePath()),
      );
      await reset();

      // Delete file.
      await tempFile.delete();
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempFile.uri.toFilePath()),
      );
      await reset();

      // Add file to tracked directory.
      final subFile2 = fileSystem.file(tempSubDir.uri.resolve('baz.txt'));
      await subFile2.create(recursive: true);
      await subFile2.writeAsString('hello');
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempSubDir.uri.toFilePath()),
      );
      await reset();

      // Delete file from tracked directory.
      await subFile.delete();
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempSubDir.uri.toFilePath()),
      );
      await reset();

      // Delete tracked directory.
      await tempSubDir.delete(recursive: true);
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempSubDir.uri.toFilePath()),
      );
      await reset();

      // Add directory to tracked directory.
      final subDir2 = fileSystem.directory(tempSubDir.uri.resolve('baz/'));
      await subDir2.create(recursive: true);
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempSubDir.uri.toFilePath()),
      );
      await reset();

      // Overwriting a file with identical contents.
      await tempFile.writeAsString('something something');
      await tempFile.writeAsString('hello');
      expect(await hashes.findOutdatedDependency(environment), isNull);
      await reset();

      // If a file is modified after the valid timestamp, it should be marked
      // as changed.
      await hashes.updateHashes(
        [tempFile.uri],
        (await tempFile.lastModified()).subtract(const Duration(seconds: 1)),
        environment,
      );
      expect(
        await hashes.findOutdatedDependency(environment),
        contains(tempFile.uri.toFilePath()),
      );
    });
  });
}
