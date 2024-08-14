// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
// TODO(https://github.com/dart-lang/native/issues/1415): Enable support
// for Windows once linker flags are supported by CBuilder.
@TestOn('!windows')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
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
      final testPackageUri = packageUri.resolve('example/build/$name/');
      final dartUri = Uri.file(Platform.resolvedExecutable);

      final processResult = await Process.run(
        dartUri.toFilePath(),
        [
          'hook/build.dart',
          '-Dout_dir=${tempUri.toFilePath()}',
          '-Dpackage_name=$name',
          '-Dpackage_root=${testPackageUri.toFilePath()}',
          '-Dtarget_os=${OSImpl.current}',
          '-Dversion=${HookConfigImpl.latestVersion}',
          '-Dlink_mode_preference=dynamic',
          '-Ddry_run=$dryRun',
          if (!dryRun) ...[
            '-Dtarget_architecture=${ArchitectureImpl.current}',
            '-Dbuild_mode=debug',
            if (cc != null) '-Dcc=${cc!.toFilePath()}',
            if (envScript != null)
              '-D${CCompilerConfigImpl.envScriptConfigKeyFull}='
                  '${envScript!.toFilePath()}',
            if (envScriptArgs != null)
              '-D${CCompilerConfigImpl.envScriptArgsConfigKeyFull}='
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
      }
    });
  }
}
