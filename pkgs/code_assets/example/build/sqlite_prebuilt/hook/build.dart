// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/digests/sha3.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final codeConfig = input.config.code;
      if (codeConfig.targetOS != OS.current ||
          codeConfig.targetArchitecture != Architecture.current) {
        throw UnsupportedError(
          'This package only supports running on the host platform. '
          'Please use a different sqlite package for cross compilation.',
        );
      }

      output.assets.code.add(
        // Asset ID: "package:sqlite_prebuilt/src/third_party/sqlite3.g.dart"
        CodeAsset(
          package: 'sqlite_prebuilt',
          name: 'src/third_party/sqlite3.g.dart',
          linkMode: DynamicLoadingBundled(),
          file: await _downloadOrFindLibsqlite3(input.outputDirectoryShared),
        ),
      );
    }
  });
}

const _windowsDownloadInfo = {
  Architecture.arm64: (
    url: 'https://sqlite.org/2025/sqlite-dll-win-arm64-3500400.zip',
    sha256: 'c4f3d245377f4ee2da5c08e882ecaff376b35a609198dc399dd8cec0add1ea43',
  ),
  Architecture.x64: (
    url: 'https://sqlite.org/2025/sqlite-dll-win-x64-3500400.zip',
    sha256: '8454a8ef362b4b2d5a259a54948ed278ef943128bf1ba74b5cbd87ebc58e5b85',
  ),
};

Future<Uri?> _downloadOrFindLibsqlite3(Uri outputDirectory) async {
  switch (OS.current) {
    case OS.windows:
      final extractDir = Directory.fromUri(
        outputDirectory.resolve('download/'),
      );
      final dll = File.fromUri(extractDir.uri.resolve('sqlite3.dll'));
      if (await dll.exists()) {
        return dll.uri;
      }

      final url = Uri.parse(_windowsDownloadInfo[Architecture.current]!.url);
      print('Downloading $url.');
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception(
          'Error downloading file: Status code ${response.statusCode}',
        );
      }

      final computedHash = SHA3Digest(256)
          .process(response.bodyBytes)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('');
      final expectedHash = _windowsDownloadInfo[Architecture.current]!.sha256;
      if (computedHash != expectedHash) {
        throw Exception(
          'Download failed, invalid hash: $computedHash, '
          'excpected $expectedHash.',
        );
      }

      print('Download complete. Unzipping.');
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);

      if (!await extractDir.exists()) {
        await extractDir.create(recursive: true);
      }
      for (final file in archive) {
        if (!file.isFile) {
          throw UnimplementedError('Did not expect directory in zip file');
        }
        final data = file.content as List<int>;
        final targetFile = File.fromUri(extractDir.uri.resolve(file.name));
        await targetFile.create(recursive: true);
        await targetFile.writeAsBytes(data);
      }

      print(
        'Successfully unzipped files to the "${extractDir.path}" directory.',
      );
      if (!await dll.exists()) {
        throw Exception('Did not find sqlite3.dll in $extractDir');
      }
      return dll.uri;

    case OS.macOS:
      // No prebuilt binaries are downloadable on the SQLite website. Let's use
      // a package manager instead: Brew. Require the user to install SQLite via
      // Brew.
      final brewPrefixResult = Process.runSync('brew', ['--prefix', 'sqlite']);
      if (brewPrefixResult.exitCode != 0) {
        print(brewPrefixResult.stderr);
        throw UnsupportedError(
          'Install brew and then install sqlite with brew.',
        );
      }
      final sqliteDir = Uri.directory(
        File(
          (brewPrefixResult.stdout as String).trim(),
        ).resolveSymbolicLinksSync(),
      );
      final libsqliteFile = File.fromUri(
        sqliteDir.resolve('lib/libsqlite3.dylib'),
      ).resolveSymbolicLinksSync();
      return Uri.file(libsqliteFile);
    default:
  }
  throw UnimplementedError();
}
