// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:native_assets_builder/src/file_system_cache/file_system_cache.dart';
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

  test('file system cache', () async {
    await inTempDir((tempUri) async {
      final tempFile = File.fromUri(tempUri.resolve('foo.txt'));
      final tempSubDir = Directory.fromUri(tempUri.resolve('subdir/'));
      final subFile = File.fromUri(tempSubDir.uri.resolve('bar.txt'));

      final cacheFile = File.fromUri(tempUri.resolve('cache.json'));
      final cache = FileSystemCache(cacheFile: cacheFile);

      Future<void> reset() async {
        await tempFile.create(recursive: true);
        await tempSubDir.create(recursive: true);
        await subFile.create(recursive: true);
        await tempFile.writeAsString('hello');
        await subFile.writeAsString('world');

        cache.reset();
        await cache.hashFiles([
          tempFile.uri,
          tempSubDir.uri,
        ]);
        await cache.persist();
        expect(await cache.findOutdatedFileSystemEntity(), isNull);
      }

      await reset();

      // Change file contents.
      await tempFile.writeAsString('asdf');
      expect(await cache.findOutdatedFileSystemEntity(), tempFile.uri);
      await reset();

      // Delete file.
      await tempFile.delete();
      expect(await cache.findOutdatedFileSystemEntity(), tempFile.uri);
      await reset();

      // Add file to tracked directory.
      final subFile2 = File.fromUri(tempSubDir.uri.resolve('baz.txt'));
      await subFile2.create(recursive: true);
      await subFile2.writeAsString('hello');
      expect(await cache.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Delete file from tracked directory.
      await subFile.delete();
      expect(await cache.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Delete tracked directory.
      await tempSubDir.delete(recursive: true);
      expect(await cache.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Add directory to tracked directory.
      final subDir2 = Directory.fromUri(tempSubDir.uri.resolve('baz/'));
      await subDir2.create(recursive: true);
      expect(await cache.findOutdatedFileSystemEntity(), tempSubDir.uri);
      await reset();

      // Overwriting a file with identical contents.
      await tempFile.writeAsString('something something');
      await tempFile.writeAsString('hello');
      expect(await cache.findOutdatedFileSystemEntity(), isNull);
      await reset();

      // If a file is modified after the valid timestamp, it should be marked
      // as changed.
      cache.reset();
      await cache.hashFiles(
        [
          tempFile.uri,
        ],
        validBeforeLastModified: (await tempFile.lastModified())
            .subtract(const Duration(seconds: 1)),
      );
      expect(await cache.findOutdatedFileSystemEntity(), tempFile.uri);
      await reset();

      // Read a cache from file.
      final cacheFromFile = FileSystemCache(cacheFile: cacheFile);
      await cacheFromFile.readCacheFile();
      expect(await cacheFromFile.findOutdatedFileSystemEntity(), isNull);
    });
  });
}
