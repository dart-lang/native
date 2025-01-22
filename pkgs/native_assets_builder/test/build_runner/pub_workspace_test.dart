// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file/local.dart';
import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() async {
  late Uri tempUri;
  setUp(() async {
    tempUri = await tempDirForTest();
    await copyTestProjects(targetUri: tempUri);
  });

  Future<void> makePubWorkspace(List<String> packages) async {
    for (final package in packages) {
      final packageUri = tempUri.resolve('$package/');
      final pubspecUri = packageUri.resolve('pubspec.yaml');
      var pubspec = await File.fromUri(pubspecUri).readAsString();
      pubspec += '''

resolution: workspace
''';
      await File.fromUri(pubspecUri).writeAsString(pubspec);
    }

    final workspacePubSpecUri = tempUri.resolve('pubspec.yaml');
    var workspacePubSpec = '''
name: dart_lang_native_workspace

environment:
  sdk: ^3.6.0

workspace:
''';
    for (final package in packages) {
      workspacePubSpec += '''
  - $package/
''';
    }
    await File.fromUri(workspacePubSpecUri).writeAsString(workspacePubSpec);

    await runPubGet(
      workingDirectory: tempUri,
      logger: logger,
    );
  }

  test('pub workspaces', () async {
    final packageUri = tempUri.resolve('named_add_renamed/');
    await Directory.fromUri(tempUri.resolve('native_add/'))
        .rename(packageUri.toFilePath());
    await makePubWorkspace([
      'dart_app',
      'native_subtract',
      // Do not fail on package with different name than directory
      'named_add_renamed',
      // Do not fail on issues on packages not in dependencies.
      'cyclic_package_1',
      'cyclic_package_2',
    ]);

    (await buildCodeAssets(packageUri, runPackageName: 'native_add'))!;
    final buildDirectory = tempUri.resolve('.dart_tool/native_assets_builder/');
    final buildDirs = Directory.fromUri(buildDirectory)
        .listSync()
        .whereType<Directory>()
        .map((e) => e.uri.pathSegments.lastWhere((e) => e.isNotEmpty))
        .toList()
      ..sort();
    expect(buildDirs, contains('native_add'));
    // Do not build packages not in dependencies of runPackageName.
    expect(buildDirs, isNot(contains('native_subtract')));

    final logs = <String>[];
    (await buildCodeAssets(
      tempUri.resolve('dart_app/'),
      capturedLogs: logs,
    ))!;
    // Reuse hook results of other packages in the same workspace
    expect(logs.join('\n'), contains('Skipping build for native_add'));
  });

  test('hasBuildHooks', () async {
    const fileSystem = LocalFileSystem();
    final packageUri = tempUri.resolve('no_hook/');
    await makePubWorkspace([
      // Some package that has no hooks and has no dependencies with hooks.
      'no_hook',
      // Some unrelated package with native assets.
      'dart_app',
      'native_add',
      'native_subtract',
    ]);
    for (final (runPackageName, hasBuildHooks) in [
      ('no_hook', false),
      ('dart_app', true),
    ]) {
      final packageLayoutNoHook = await PackageLayout.fromWorkingDirectory(
        fileSystem,
        packageUri,
        runPackageName,
      );
      final builderNoHook = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        fileSystem: fileSystem,
        packageLayout: packageLayoutNoHook,
      );
      expect(await builderNoHook.hasBuildHooks(), equals(hasBuildHooks));
    }
  });
}
