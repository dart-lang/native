// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  late Uri tempUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  for (final dryRun in [true, false]) {
    final testSuffix = dryRun ? ' dry_run' : '';
    test('native_add build$testSuffix', () async {
      final testTempUri = tempUri.resolve('test1/');
      await Directory.fromUri(testTempUri).create();
      final testPackageUri = packageUri.resolve('example/native_add_library/');
      final dartUri = Uri.file(Platform.resolvedExecutable);

      final processResult = await Process.run(
        dartUri.toFilePath(),
        [
          'build.dart',
          '-Dout_dir=${tempUri.toFilePath()}',
          '-Dpackage_root=${testPackageUri.toFilePath()}',
          '-Dtarget_os=${OS.current}',
          '-Dversion=${BuildConfig.version}',
          '-Dlink_mode_preference=dynamic',
          '-Ddry_run=$dryRun',
          if (!dryRun) ...[
            '-Dtarget_architecture=${Architecture.current}',
            '-Dbuild_mode=debug',
            if (cc != null) '-Dcc=${cc!.toFilePath()}',
            if (envScript != null)
              '-D${CCompilerConfig.envScriptConfigKeyFull}='
                  '${envScript!.toFilePath()}',
            if (envScriptArgs != null)
              '-D${CCompilerConfig.envScriptArgsConfigKeyFull}='
                  '${envScriptArgs!.join(' ')}',
          ],
        ],
        workingDirectory: testPackageUri.toFilePath(),
      );
      if (processResult.exitCode != 0) {
        print(processResult.stdout);
        print(processResult.stderr);
        print(processResult.exitCode);
      }
      expect(processResult.exitCode, 0);

      final buildOutputUri = tempUri.resolve('build_output.yaml');
      final buildOutput = BuildOutput.fromYamlString(
          await File.fromUri(buildOutputUri).readAsString());
      final assets = buildOutput.assets;
      final dependencies = buildOutput.dependencies;
      if (dryRun) {
        expect(assets.length, greaterThanOrEqualTo(1));
        expect(await assets.first.exists(), false);
        expect(dependencies.dependencies, <Uri>[]);
      } else {
        expect(assets.length, 1);
        expect(await assets.allExist(), true);
        expect(
          dependencies.dependencies,
          [
            testPackageUri.resolve('src/native_add_library.c'),
            testPackageUri.resolve('build.dart'),
          ],
        );
      }
    });
  }
}
