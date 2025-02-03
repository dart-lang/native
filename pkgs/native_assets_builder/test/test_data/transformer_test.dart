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

      final buildOutputUri = tempUri.resolve('build_output.json');
      final outputDirectory = tempUri.resolve('out/');
      await Directory.fromUri(outputDirectory).create();
      final outputDirectoryShared = tempUri.resolve('out_shared/');
      await Directory.fromUri(outputDirectoryShared).create();
      final testTempUri = tempUri.resolve('test1/');
      await Directory.fromUri(testTempUri).create();
      final dartUri = Uri.file(Platform.resolvedExecutable);

      late String stdout;
      late BuildOutput output;

      final targetOS = OS.current;
      Future<void> runBuild(Architecture architecture) async {
        final inputBuilder = BuildInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: packageUri,
            outputFile: buildOutputUri,
            outputDirectory: outputDirectory,
            outputDirectoryShared: outputDirectoryShared,
          )
          ..config.setupBuild(dryRun: false, linkingEnabled: false)
          ..config.setupShared(buildAssetTypes: [
            CodeAsset.type,
            DataAsset.type,
          ])
          ..config.setupCode(
            targetArchitecture: architecture,
            targetOS: targetOS,
            macOS: targetOS == OS.macOS
                ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
                : null,
            linkModePreference: LinkModePreference.dynamic,
          );

        final buildInputUri = testTempUri.resolve('build_input.json');
        File.fromUri(buildInputUri)
            .writeAsStringSync(jsonEncode(inputBuilder.json));

        final processResult = await Process.run(
          dartUri.toFilePath(),
          [
            'hook/build.dart',
            '--config=${buildInputUri.toFilePath()}',
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

        output = BuildOutput(
            json.decode(await File.fromUri(buildOutputUri).readAsString())
                as Map<String, Object?>);
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
        output.assets.data,
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
