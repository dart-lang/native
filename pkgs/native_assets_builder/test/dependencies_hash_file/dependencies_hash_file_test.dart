// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:native_assets_builder/src/dependencies_hash_file/dependencies_hash_file.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  test('json format', () async {
    await inTempDir((tempUri) async {
      final hashes = FileSystemHashes(
        files: [
          FilesystemEntityHash(
            tempUri.resolve('foo.dll'),
            1337,
          ),
        ],
      );
      final hashes2 = FileSystemHashes.fromJson(hashes.toJson());
      expect(hashes.files.single.path, equals(hashes2.files.single.path));
      expect(hashes.files.single.hash, equals(hashes2.files.single.hash));
    });
  });

  test('dependencies hash file', () async {
    await inTempDir((tempUri) async {
      final tempFile = File.fromUri(tempUri.resolve('foo.txt'));
      final tempSubDir = Directory.fromUri(tempUri.resolve('subdir/'));
      final subFile = File.fromUri(tempSubDir.uri.resolve('bar.txt'));

      final hashesFile = File.fromUri(tempUri.resolve('hashes.json'));
      final hashes = DependenciesHashFile(file: hashesFile);

      Future<void> reset() async {
        await tempFile.create(recursive: true);
        await tempSubDir.create(recursive: true);
        await subFile.create(recursive: true);
        await tempFile.writeAsString('hello');
        await subFile.writeAsString('world');

        await hashes.hashFilesAndDirectories([
          tempFile.uri,
          tempSubDir.uri,
        ]);
      }

      await reset();

      // No changes
      expect(await hashes.findOutdatedFileSystemEntity(), isNull);

      // Change file contents.
      await tempFile.writeAsString('asdf');
      expect(await hashes.findOutdatedFileSystemEntity(), tempFile.uri);
      await reset();

      // Delete file.
      await tempFile.delete();
      expect(await hashes.findOutdatedFileSystemEntity(), tempFile.uri);
      await reset();

      // Add file to tracked directory.
      final subFile2 = File.fromUri(tempSubDir.uri.resolve('baz.txt'));
      await subFile2.create(recursive: true);
      await subFile2.writeAsString('hello');
      expect(await hashes.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Delete file from tracked directory.
      await subFile.delete();
      expect(await hashes.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Delete tracked directory.
      await tempSubDir.delete(recursive: true);
      expect(await hashes.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Add directory to tracked directory.
      final subDir2 = Directory.fromUri(tempSubDir.uri.resolve('baz/'));
      await subDir2.create(recursive: true);
      expect(await hashes.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Overwriting a file with identical contents.
      await tempFile.writeAsString('something something');
      await tempFile.writeAsString('hello');
      expect(await hashes.findOutdatedFileSystemEntity(), isNull);
      await reset();

      // If a file is modified after the valid timestamp, it should be marked
      // as changed.
      await hashes.hashFilesAndDirectories(
        [
          tempFile.uri,
        ],
        validBeforeLastModified: (await tempFile.lastModified())
            .subtract(const Duration(seconds: 1)),
      );
      expect(await hashes.findOutdatedFileSystemEntity(), tempFile.uri);
    });
  });
}
