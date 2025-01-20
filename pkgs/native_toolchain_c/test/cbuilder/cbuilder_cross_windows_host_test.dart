// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('windows')
@OnPlatform({
  'windows': Timeout.factor(10),
})
library;

import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final compilers = {
    // Either provided to be MSVC or null which defaults to MSVC.
    msvc: () async => cCompiler,
    // Clang on Windows.
    clang: () async => CCompilerConfig(
          archiver:
              (await llvmAr.defaultResolver!.resolve(logger: logger)).first.uri,
          compiler:
              (await clang.defaultResolver!.resolve(logger: logger)).first.uri,
          linker:
              (await lld.defaultResolver!.resolve(logger: logger)).first.uri,
          windows: WindowsCCompilerConfig(),
        )
  };

  const targets = [
    // TODO(https://github.com/dart-lang/native/issues/170): Support arm64.
    // Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
  ];

  late Uri dumpbinUri;

  setUp(() async {
    dumpbinUri =
        (await dumpbin.defaultResolver!.resolve(logger: logger)).first.uri;
  });

  const dumpbinMachine = {
    Architecture.arm64: 'ARM64',
    Architecture.ia32: 'x86',
    Architecture.x64: 'x64',
  };

  const optimizationLevels = OptimizationLevel.values;
  var selectOptimizationLevel = 0;
  var selectBuildMode = 0;

  final dumpbinFileType = {
    DynamicLoadingBundled(): 'DLL',
    StaticLinking(): 'LIBRARY',
  };

  for (final compiler in compilers.keys) {
    for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
      for (final target in targets) {
        // Cycle through all optimization levels.
        final optimizationLevel = optimizationLevels[selectOptimizationLevel];
        selectOptimizationLevel =
            (selectOptimizationLevel + 1) % optimizationLevels.length;
        final buildMode = BuildMode.values[selectBuildMode];
        selectBuildMode = (selectBuildMode + 1) % BuildMode.values.length;
        test(
            'CBuilder ${compiler.name} $linkMode library $target'
            ' $optimizationLevel $buildMode', () async {
          final tempUri = await tempDirForTest();
          final tempUri2 = await tempDirForTest();
          final addCUri =
              packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
          const name = 'add';

          final buildInputBuilder = BuildInputBuilder()
            ..setupShared(
              packageName: name,
              packageRoot: tempUri,
              outputFile: tempUri.resolve('output.json'),
              outputDirectory: tempUri,
              outputDirectoryShared: tempUri2,
            )
            ..config.setupBuild(
              linkingEnabled: false,
              dryRun: false,
            )
            ..config.setupShared(buildAssetTypes: [CodeAsset.type])
            ..config.setupCode(
              targetOS: OS.windows,
              targetArchitecture: target,
              linkModePreference: linkMode == DynamicLoadingBundled()
                  ? LinkModePreference.dynamic
                  : LinkModePreference.static,
              cCompiler: await (compilers[compiler]!)(),
            );

          final buildInput = BuildInput(buildInputBuilder.json);
          final buildOutput = BuildOutputBuilder();

          final cbuilder = CBuilder.library(
            name: name,
            assetName: name,
            sources: [addCUri.toFilePath()],
            optimizationLevel: optimizationLevel,
            buildMode: buildMode,
          );
          await cbuilder.run(
            input: buildInput,
            output: buildOutput,
            logger: logger,
          );

          final libUri =
              tempUri.resolve(OS.windows.libraryFileName(name, linkMode));
          expect(await File.fromUri(libUri).exists(), true);
          final result = await runProcess(
            executable: dumpbinUri,
            arguments: ['/HEADERS', libUri.toFilePath()],
            logger: logger,
          );
          expect(result.exitCode, 0);
          final machine = result.stdout
              .split('\n')
              .firstWhere((e) => e.contains('machine'));
          expect(machine, contains(dumpbinMachine[target]));
          final fileType = result.stdout
              .split('\n')
              .firstWhere((e) => e.contains('File Type'));
          expect(fileType, contains(dumpbinFileType[linkMode]));
        });
      }
    }
  }
}
