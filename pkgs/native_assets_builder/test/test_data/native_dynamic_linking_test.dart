// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../build_runner/helpers.dart';
import '../helpers.dart';

void main() async {
  const name = 'native_dynamic_linking';

  test(
    'native_dynamic_linking build',
    () => inTempDir((tempUri) async {
      final buildOutputUri = tempUri.resolve('build_output.json');
      final outputDirectory = tempUri.resolve('out/');
      await Directory.fromUri(outputDirectory).create();
      final outputDirectoryShared = tempUri.resolve('out_shared/');
      await Directory.fromUri(outputDirectoryShared).create();
      final testTempUri = tempUri.resolve('test1/');
      await Directory.fromUri(testTempUri).create();
      final testPackageUri = testDataUri.resolve('$name/');
      final dartUri = Uri.file(Platform.resolvedExecutable);

      final targetOS = OS.current;
      final inputBuilder =
          BuildInputBuilder()
            ..setupShared(
              packageName: name,
              packageRoot: testPackageUri,
              outputFile: buildOutputUri,
              outputDirectory: outputDirectory,
              outputDirectoryShared: outputDirectoryShared,
            )
            ..config.setupBuild(linkingEnabled: false)
            ..config.setupShared(buildAssetTypes: [CodeAsset.type])
            ..config.setupCode(
              targetArchitecture: Architecture.current,
              targetOS: targetOS,
              macOS:
                  targetOS == OS.macOS
                      ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
                      : null,
              linkModePreference: LinkModePreference.dynamic,
              cCompiler: cCompiler,
            );

      final buildInputUri = testTempUri.resolve('build_input.json');
      File.fromUri(
        buildInputUri,
      ).writeAsStringSync(jsonEncode(inputBuilder.json));

      await runPubGet(workingDirectory: testPackageUri, logger: logger);

      final processResult = await Process.run(dartUri.toFilePath(), [
        'hook/build.dart',
        '--config=${buildInputUri.toFilePath()}',
      ], workingDirectory: testPackageUri.toFilePath());
      if (processResult.exitCode != 0) {
        print(processResult.stdout);
        print(processResult.stderr);
        print(processResult.exitCode);
      }
      expect(processResult.exitCode, 0);

      final buildOutput = BuildOutput(
        json.decode(await File.fromUri(buildOutputUri).readAsString())
            as Map<String, Object?>,
      );
      final assets = buildOutput.assets.encodedAssets;
      final dependencies = buildOutput.dependencies;

      expect(assets.length, 3);
      expect(await assets.allExist(), true);
      expect(dependencies, [
        testPackageUri.resolve('src/debug.c'),
        testPackageUri.resolve('src/math.c'),
        testPackageUri.resolve('src/add.c'),
      ]);

      final addLibraryPath =
          assets
              .where((e) => e.type == CodeAsset.type)
              .map(CodeAsset.fromEncoded)
              .firstWhere((asset) => asset.id.endsWith('add.dart'))
              .file!
              .toFilePath();
      final addResult = await runProcess(
        executable: dartExecutable,
        arguments: [
          'run',
          pkgNativeAssetsBuilderUri
              .resolve('test/test_data/native_dynamic_linking_helper.dart')
              .toFilePath(),
          addLibraryPath,
          '1',
          '2',
        ],
        environment: {
          // Add the directory containing the linked dynamic libraries to
          // the PATH so that the dynamic linker can find them.
          // TODO(https://github.com/dart-lang/sdk/issues/56551): We could
          // skip this if Dart would implicitly add dylib containing
          // directories to the PATH.
          if (Platform.isWindows)
            'PATH':
                '${outputDirectory.toFilePath()};'
                '${Platform.environment['PATH']}',
        },
        throwOnUnexpectedExitCode: true,
        logger: logger,
      );
      expect(
        addResult.stdout,
        allOf(contains('Adding 1 and 2.'), contains('Result: 3')),
      );
    }),
  );
}

int defaultMacOSVersion = 13;
