// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:c_compiler/c_compiler.dart';
import 'package:c_compiler/src/utils/run_process.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('Cbuilder executable', () async {
    await inTempDir((tempUri) async {
      final helloWorldCUri = packageUri
          .resolve('test/cbuilder/testfiles/hello_world/src/hello_world.c');
      if (!await File.fromUri(helloWorldCUri).exists()) {
        throw Exception('Run the test from the root directory.');
      }
      const name = 'hello_world';

      final buildConfig = BuildConfig(
        outDir: tempUri,
        packageRoot: tempUri,
        target: Target.current,
        packaging: PackagingPreference.dynamic, // Ignored by executables.
        cc: cc,
        toolchainEnvScript: toolchainEnvScript,
        toolchainEnvScriptArgs: toolchainEnvScriptArgs,
      );
      final buildOutput = BuildOutput();
      final cbuilder = CBuilder.executable(
        name: name,
        sources: [helloWorldCUri.toFilePath()],
      );
      await cbuilder.run(
        buildConfig: buildConfig,
        buildOutput: buildOutput,
        logger: logger,
      );

      final executableUri =
          tempUri.resolve(Target.current.os.executableFileName(name));
      expect(await File.fromUri(executableUri).exists(), true);
      final result = await runProcess(
        executable: executableUri,
        logger: logger,
      );
      expect(result.exitCode, 0);
      expect(result.stdout.trim(), 'Hello world.');
    });
  });

  test('Cbuilder dylib', () async {
    await inTempDir(
      // https://github.com/dart-lang/sdk/issues/40159
      keepTemp: Platform.isWindows,
      (tempUri) async {
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final buildConfig = BuildConfig(
          outDir: tempUri,
          packageRoot: tempUri,
          target: Target.current,
          packaging: PackagingPreference.dynamic,
          cc: cc,
          toolchainEnvScript: toolchainEnvScript,
          toolchainEnvScriptArgs: toolchainEnvScriptArgs,
        );
        final buildOutput = BuildOutput();

        final cbuilder = CBuilder.library(
          sources: [addCUri.toFilePath()],
          name: name,
          assetName: name,
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final dylibUri = tempUri.resolve(Target.current.os.dylibFileName(name));
        expect(await File.fromUri(dylibUri).exists(), true);
        final dylib = DynamicLibrary.open(dylibUri.toFilePath());
        final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
            int Function(int, int)>('add');
        expect(add(1, 2), 3);
      },
    );
  });
}
