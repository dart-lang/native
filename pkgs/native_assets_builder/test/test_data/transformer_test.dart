// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
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

import '../build_runner/helpers.dart';
import '../helpers.dart';

void main() async {
  const packageName = 'transformer';

  test(
    'transformer caching',
    () => inTempDir((tempUri) async {
      final packageUri = tempUri.resolve('$packageName/');
      await copyTestProjects(
        sourceUri: testDataUri.resolve('$packageName/'),
        targetUri: packageUri,
      );

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final outputDirectory = tempUri.resolve('out/');
      await Directory.fromUri(outputDirectory).create();
      final outputDirectoryShared = tempUri.resolve('out_shared/');
      await Directory.fromUri(outputDirectoryShared).create();
      final testTempUri = tempUri.resolve('test1/');
      await Directory.fromUri(testTempUri).create();
      final dartUri = Uri.file(Platform.resolvedExecutable);

      late String stdout;
      late HookOutputImpl output;

      Future<void> runBuild(Architecture architecture) async {
        final config = BuildConfigImpl(
          outputDirectory: outputDirectory,
          outputDirectoryShared: outputDirectoryShared,
          packageName: packageName,
          packageRoot: packageUri,
          targetOS: OS.current,
          version: HookConfigImpl.latestVersion,
          linkModePreference: LinkModePreference.dynamic,
          dryRun: false,
          linkingEnabled: false,
          targetArchitecture: architecture,
          buildMode: BuildMode.debug,
          supportedAssetTypes: [DataAsset.type],
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
          workingDirectory: packageUri.toFilePath(),
        );
        if (processResult.exitCode != 0) {
          print(processResult.stdout);
          print(processResult.stderr);
          print(processResult.exitCode);
        }
        expect(processResult.exitCode, 0);
        stdout = processResult.stdout as String;

        final buildOutputUri = outputDirectory.resolve('build_output.json');
        output = HookOutputImpl.fromJsonString(
            await File.fromUri(buildOutputUri).readAsString());
      }

      await runBuild(Architecture.x64);
      expect(
        stdout,
        stringContainsInOrder([
          'Transformed 10 files.',
          'Reused 0 cached files.',
        ]),
      );
      expect(
        output.assets,
        contains(
          DataAsset(
            file: outputDirectoryShared.resolve('data_transformed0.json'),
            name: 'data_transformed0.json',
            package: packageName,
          ),
        ),
      );
      expect(
        output.dependencies,
        containsAll([
          packageUri.resolve('data/'),
          packageUri.resolve('data/data0.json'),
        ]),
      );

      await File.fromUri(packageUri.resolve('data/data0.json')).writeAsString(
        jsonEncode({'foo': 'bar'}),
      );

      // Run the build for a different architecture.
      // This should use the caching inside the hook.
      await runBuild(Architecture.arm64);
      expect(
        stdout,
        stringContainsInOrder([
          'Transformed 1 files.',
          'Reused 9 cached files.',
        ]),
      );
    }),
  );
}
