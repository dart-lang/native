// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({'mac-os': Timeout.factor(2)})
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    (OS.macOS, Architecture.arm64),
    (OS.macOS, Architecture.x64),
    (OS.linux, Architecture.arm),
    (OS.linux, Architecture.arm64),
    (OS.linux, Architecture.ia32),
    (OS.linux, Architecture.x64),

    // Not supported by Apple Clang right now.
    // (OS.linux, Architecture.riscv32),
    // (OS.linux, Architecture.riscv64),
  ];

  // Dont include 'mach-o' or 'Mach-O', different spelling is used.
  const objdumpFileFormat = {
    (OS.macOS, Architecture.arm64): 'arm64',
    (OS.macOS, Architecture.x64): '64-bit x86-64',
    (OS.linux, Architecture.arm): 'elf32-littlearm',
    (OS.linux, Architecture.arm64): 'elf64-littleaarch64',
    (OS.linux, Architecture.ia32): 'elf32-i386',
    (OS.linux, Architecture.x64): 'elf64-x86-64',

    (OS.linux, Architecture.riscv32): 'elf32-riscv32',
    (OS.linux, Architecture.riscv64): 'elf64-riscv64',
  };

  const optimizationLevels = OptimizationLevel.values;
  var selectOptimizationLevel = 0;

  for (final language in [Language.c, Language.objectiveC]) {
    for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
      for (final (os, arch) in targets) {
        // Don't build Objective-C targets for linux.
        if (language == Language.objectiveC && os == OS.linux) continue;

        // Cycle through all optimization levels.
        final optimizationLevel = optimizationLevels[selectOptimizationLevel];
        selectOptimizationLevel =
            (selectOptimizationLevel + 1) % optimizationLevels.length;

        test(
          'CBuilder $linkMode $language library $os $arch $optimizationLevel',
          () async {
            final tempUri = await tempDirForTest();
            final tempUri2 = await tempDirForTest();
            final sourceUri = switch (language) {
              Language.c => packageUri.resolve(
                'test/cbuilder/testfiles/add/src/add.c',
              ),
              Language.objectiveC => packageUri.resolve(
                'test/cbuilder/testfiles/add_objective_c/src/add.m',
              ),
              Language() => throw UnimplementedError(),
            };
            const name = 'add';

            // When cross-compiling from MacOS, explicitly specify apple clang.
            //
            // The default tool-finding does not support macos cross compiling right now.
            var chosenCCompiler = cCompiler;
            if (os == OS.linux) {
              // still respect the CI-provided compiler
              chosenCCompiler ??= await resolveAppleToolchain();
            }

            final buildInputBuilder = BuildInputBuilder()
              ..setupShared(
                packageName: name,
                packageRoot: tempUri,
                outputFile: tempUri.resolve('output.json'),
                outputDirectoryShared: tempUri2,
              )
              ..config.setupBuild(linkingEnabled: false)
              ..addExtension(
                CodeAssetExtension(
                  targetOS: os,
                  targetArchitecture: arch,
                  linkModePreference: linkMode == DynamicLoadingBundled()
                      ? LinkModePreference.dynamic
                      : LinkModePreference.static,
                  cCompiler: chosenCCompiler,
                  macOS: MacOSCodeConfig(targetVersion: defaultMacOSVersion),
                ),
              );
            final buildInput = buildInputBuilder.build();
            final buildOutput = BuildOutputBuilder();

            final cbuilder = CBuilder.library(
              name: name,
              assetName: name,
              sources: [sourceUri.toFilePath()],
              language: language,
              optimizationLevel: optimizationLevel,
              buildMode: BuildMode.release,
              flags: [
                if (os == OS.linux)
                  switch (arch) {
                    Architecture.arm => '--target=arm-linux-gnueabihf',
                    Architecture.arm64 => '--target=aarch64-linux-gnu',
                    Architecture.ia32 => '--target=i686-linux-gnu',
                    Architecture.x64 => '--target=x86_64-linux-gnu',
                    Architecture.riscv32 => '--target=riscv32-linux-gnu',
                    Architecture.riscv64 => '--target=riscv64-linux-gnu',
                    _ => throw UnsupportedError(
                      'Unexpected linux architecture: $arch',
                    ),
                  },
                // Only homebrew lld can link for linux, and we don't have a sysroot
                // so we can't use stdlibs / C-runtime files.
                if (os == OS.linux) ...[
                  '--ld-path=ld.lld',
                  '-nostartfiles',
                  '-nostdlib',
                ],
              ],
            );
            await cbuilder.run(
              input: buildInput,
              output: buildOutput,
              logger: logger,
            );

            final libUri = buildInput.outputDirectory.resolve(
              os.libraryFileName(name, linkMode),
            );
            final result = await runProcess(
              executable: Uri.file('objdump'),
              arguments: ['-t', libUri.path],
              logger: logger,
            );
            expect(result.exitCode, 0);
            final machine = result.stdout
                .split('\n')
                .firstWhere((e) => e.contains('file format'));
            expect(machine, contains(objdumpFileFormat[(os, arch)]));
          },
        );
      }
    }
  }

  const flutterMacOSLowestBestEffort = 12;
  const flutterMacOSLowestSupported = 13;

  for (final macosVersion in [
    flutterMacOSLowestBestEffort,
    flutterMacOSLowestSupported,
  ]) {
    for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
      test('$linkMode macos min version $macosVersion', () async {
        const target = Architecture.arm64;
        final tempUri = await tempDirForTest();
        final out1Uri = tempUri.resolve('out1/');
        await Directory.fromUri(out1Uri).create();
        final out2Uri = tempUri.resolve('out2/');
        await Directory.fromUri(out1Uri).create();
        final lib1Uri = await buildLib(
          out1Uri,
          out2Uri,
          target,
          macosVersion,
          linkMode,
        );

        final otoolResult = await runProcess(
          executable: Uri.file('otool'),
          arguments: ['-l', lib1Uri.path],
          logger: logger,
        );
        expect(otoolResult.exitCode, 0);
        expect(otoolResult.stdout, contains('minos $macosVersion.0'));
      });
    }
  }
}

Future<Uri> buildLib(
  Uri tempUri,
  Uri tempUri2,
  Architecture targetArchitecture,
  int targetMacOSVersion,
  LinkMode linkMode,
) async {
  final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
  const name = 'add';

  final buildInputBuilder = BuildInputBuilder()
    ..setupShared(
      packageName: name,
      packageRoot: tempUri,
      outputFile: tempUri.resolve('output.json'),
      outputDirectoryShared: tempUri2,
    )
    ..config.setupBuild(linkingEnabled: false)
    ..addExtension(
      CodeAssetExtension(
        targetOS: OS.macOS,
        targetArchitecture: targetArchitecture,
        linkModePreference: linkMode == DynamicLoadingBundled()
            ? LinkModePreference.dynamic
            : LinkModePreference.static,
        macOS: MacOSCodeConfig(targetVersion: targetMacOSVersion),
        cCompiler: cCompiler,
      ),
    );

  final buildInput = buildInputBuilder.build();
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: name,
    sources: [addCUri.toFilePath()],
    buildMode: BuildMode.release,
  );
  await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

  final libUri = buildInput.outputDirectory.resolve(
    OS.iOS.libraryFileName(name, linkMode),
  );
  return libUri;
}

Future<CCompilerConfig> resolveAppleToolchain() async {
  // (still respect the CI provided compiler)
  final context = ToolResolvingContext(logger: logger);

  final resolvedClang = await appleClang.defaultResolver!.resolve(context);
  final resolvedAr = await appleAr.defaultResolver!.resolve(context);
  final resolvedLd = await appleLd.defaultResolver!.resolve(context);

  return CCompilerConfig(
    compiler: resolvedClang.first.uri,
    archiver: resolvedAr.first.uri,
    linker: resolvedLd.first.uri,
  );
}
