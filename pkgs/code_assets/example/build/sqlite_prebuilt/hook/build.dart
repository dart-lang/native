// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

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
        // Asset ID: "package:host_name/src/host_name.dart"
        CodeAsset(
          package: 'sqlite_prebuilt',
          name: 'src/sqlite_prebuilt.dart',
          linkMode: DynamicLoadingBundled(),
          file: _findLibsqlite3s(),
        ),
      );
    }
  });
}

Uri? _findLibsqlite3s() {
  switch (OS.current) {
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
      throw UnimplementedError();
  }
}
