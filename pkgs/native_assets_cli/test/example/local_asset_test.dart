// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  late Uri tempUri;
  const name = 'local_asset';

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  for (final dryRun in [true, false]) {
    final testSuffix = dryRun ? ' dry_run' : '';
    test('local_asset build$testSuffix', () async {
      final testTempUri = tempUri.resolve('test1/');
      await Directory.fromUri(testTempUri).create();
      final outputDirectory = tempUri.resolve('out/');
      await Directory.fromUri(outputDirectory).create();
      final outputDirectoryShared = tempUri.resolve('out_shared/');
      await Directory.fromUri(outputDirectoryShared).create();
      final testPackageUri = packageUri.resolve('example/build/$name/');
      final dartUri = Uri.file(Platform.resolvedExecutable);

      final config = BuildConfigImpl(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
        packageName: name,
        packageRoot: testPackageUri,
        targetOS: OS.current,
        version: HookConfigImpl.latestVersion,
        linkModePreference: LinkModePreference.dynamic,
        dryRun: dryRun,
        linkingEnabled: false,
        targetArchitecture: dryRun ? null : Architecture.current,
        buildMode: dryRun ? null : BuildMode.debug,
        cCompiler: dryRun ? null : cCompiler,
        supportedAssetTypes: [CodeAsset.type],
      );

      final buildConfigUri = testTempUri.resolve('build_config.json');
      await File.fromUri(buildConfigUri)
          .writeAsString(jsonEncode(config.toJson()));

      final processResult = await Process.run(
        dartUri.toFilePath(),
        [
          'hook/build.dart',
          '--config=${buildConfigUri.toFilePath()}',
        ],
        workingDirectory: testPackageUri.toFilePath(),
      );
      if (processResult.exitCode != 0) {
        print(processResult.stdout);
        print(processResult.stderr);
        print(processResult.exitCode);
      }
      expect(processResult.exitCode, 0);

      final buildOutputUri = outputDirectory.resolve('build_output.json');
      final buildOutput = HookOutputImpl.fromJsonString(
          await File.fromUri(buildOutputUri).readAsString());
      final assets = buildOutput.encodedAssets;
      final dependencies = buildOutput.dependencies;
      if (dryRun) {
        expect(assets.length, greaterThanOrEqualTo(1));
        final first = assets.first;
        expect(first.type, CodeAsset.type);
        final codeAsset = CodeAsset.fromEncoded(first);
        expect(await File.fromUri(codeAsset.file!).exists(), false);
        expect(dependencies, <Uri>[]);
      } else {
        expect(assets.length, 1);
        expect(await assets.allExist(), true);
        expect(
          dependencies,
          [
            testPackageUri.resolve('assets/asset.txt'),
          ],
        );
      }
    });
  }
}
