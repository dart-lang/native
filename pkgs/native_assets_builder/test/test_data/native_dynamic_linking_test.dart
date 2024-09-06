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

import '../helpers.dart';

void main() async {
  const name = 'native_dynamic_linking';

  for (final dryRun in [true, false]) {
    final testSuffix = dryRun ? ' dry_run' : '';
    test(
      'native_dynamic_linking build$testSuffix',
      () => inTempDir((tempUri) async {
        final testTempUri = tempUri.resolve('test1/');
        await Directory.fromUri(testTempUri).create();
        final testPackageUri = testDataUri.resolve('$name/');
        final dartUri = Uri.file(Platform.resolvedExecutable);

        final config = BuildConfigImpl(
          outputDirectory: tempUri,
          packageName: name,
          packageRoot: testPackageUri,
          targetOS: OSImpl.current,
          version: HookConfigImpl.latestVersion,
          linkModePreference: LinkModePreferenceImpl.dynamic,
          dryRun: dryRun,
          linkingEnabled: false,
          targetArchitecture: dryRun ? null : ArchitectureImpl.current,
          buildMode: dryRun ? null : BuildModeImpl.debug,
          cCompiler: dryRun
              ? null
              : CCompilerConfigImpl(
                  compiler: cc,
                  envScript: envScript,
                  envScriptArgs: envScriptArgs,
                ),
        );

        final buildConfigUri = testTempUri.resolve('build_config.json');
        File.fromUri(buildConfigUri)
            .writeAsStringSync(jsonEncode(config.toJson()));

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

        final buildOutputUri = tempUri.resolve('build_output.json');
        final buildOutput = HookOutputImpl.fromJsonString(
            await File.fromUri(buildOutputUri).readAsString());
        final assets = buildOutput.assets;
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

          final addLibraryPath = assets
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
              if (Platform.isWindows)
                'PATH':
                    '${tempUri.toFilePath()};${Platform.environment['PATH']}',
            },
            throwOnUnexpectedExitCode: true,
            logger: logger,
          );
          expect(
            addResult.stdout,
            allOf(
              contains('Adding 1 and 2.'),
              contains('Result: 3'),
            ),
          );
        }
      }),
    );
  }
}
