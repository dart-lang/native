// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
// TODO(https://github.com/dart-lang/native/issues/190): Enable on windows once
// https://github.com/dart-lang/sdk/commit/903eea6bfb8ee405587f0866a1d1e92eea45d29e
// has landed in dev channel.
@TestOn('!windows')
library;

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  late Uri tempUri;
  const name = 'native_dynamic_linking';

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  for (final dryRun in [true, false]) {
    final testSuffix = dryRun ? ' dry_run' : '';
    test('native_dynamic_linking build$testSuffix', () async {
      final testTempUri = tempUri.resolve('test1/');
      await Directory.fromUri(testTempUri).create();
      final outputDirectory = tempUri.resolve('out/');
      await Directory.fromUri(outputDirectory).create();
      final outputDirectoryShared = tempUri.resolve('out_shared/');
      await Directory.fromUri(outputDirectoryShared).create();
      final testPackageUri = packageUri.resolve('example/build/$name/');
      final dartUri = Uri.file(Platform.resolvedExecutable);

      final targetOS = OS.current;
      final configBuilder = BuildConfigBuilder()
        ..setupHookConfig(
          packageRoot: testPackageUri,
          packageName: name,
          buildAssetTypes: [CodeAsset.type],
        )
        ..setupBuildRunConfig(
          outputDirectory: outputDirectory,
          outputDirectoryShared: outputDirectoryShared,
        )
        ..setupBuildConfig(linkingEnabled: false, dryRun: dryRun)
        ..setupCodeConfig(CodeConfig(
          targetOS: targetOS,
          macOSConfig: targetOS == OS.macOS
              ? MacOSConfig(targetVersion: defaultMacOSVersion)
              : null,
          targetArchitecture: dryRun ? null : Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompilerConfig: dryRun ? null : cCompiler,
        ));

      final buildConfigUri = testTempUri.resolve('build_config.json');
      await File.fromUri(buildConfigUri)
          .writeAsString(jsonEncode(configBuilder.json));

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
      final buildOutput = BuildOutput(
          json.decode(await File.fromUri(buildOutputUri).readAsString())
              as Map<String, Object?>);
      final assets = buildOutput.encodedAssets;
      final dependencies = buildOutput.dependencies;
      if (dryRun) {
        expect(assets.length, greaterThanOrEqualTo(3));
        expect(dependencies, <Uri>[]);
      } else {
        expect(assets.length, 3);
        expect(await assets.allExist(), true);
        expect(
          dependencies,
          [
            testPackageUri.resolve('src/debug.c'),
            testPackageUri.resolve('src/math.c'),
            testPackageUri.resolve('src/add.c'),
          ],
        );
      }
    });
  }
}
