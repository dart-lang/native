// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'build_testfiles.dart';

void runTreeshakeTests(
  OS targetOS,
  Architecture targetArchitecture, {
  int? androidTargetNdkApi, // Must be specified iff targetOS is OS.android.
  int? macOSTargetVersion, // Must be specified iff targetOS is OS.macos.
  int? iOSTargetVersion, // Must be specified iff targetOS is OS.iOS.
  IOSSdk? iOSTargetSdk, // Must be specified iff targetOS is OS.iOS.
}) {
  if (targetOS == OS.android) {
    ArgumentError.checkNotNull(androidTargetNdkApi, 'androidTargetNdkApi');
  }
  if (targetOS == OS.macOS) {
    ArgumentError.checkNotNull(macOSTargetVersion, 'macOSTargetVersion');
  }
  if (targetOS == OS.iOS) {
    ArgumentError.checkNotNull(iOSTargetVersion, 'iOSTargetVersion');
    ArgumentError.checkNotNull(iOSTargetSdk, 'iOSTargetSdk');
  }

  CLinker linkerManual(List<String> sources) => CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: sources,
    linkerOptions: LinkerOptions.manual(
      symbolsToKeep: ['my_other_func'],
      stripDebug: true,
      gcSections: true,
      linkerScript: switch (targetOS) {
        OS.windows => packageUri.resolve(
          'test/clinker/testfiles/linker/symbols.def',
        ),
        OS.macOS => null,
        OS.iOS => null,
        _ => packageUri.resolve('test/clinker/testfiles/linker/symbols.lds'),
      },
    ),
  );
  CLinker linkerAuto(List<String> sources) => CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: sources,
    linkerOptions: LinkerOptions.treeshake(symbolsToKeep: ['my_other_func']),
  );
  CLinker linkerAutoKeepAll(List<String> sources) => CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: sources,
    linkerOptions: LinkerOptions.treeshake(symbolsToKeep: null),
  );

  late Map<String, int> sizes;
  sizes = <String, int>{};
  for (final clinker in [
    (name: 'manual', linker: linkerManual),
    (name: 'auto', linker: linkerAuto),
    (name: 'autoEmpty', linker: linkerAutoKeepAll),
  ]) {
    test('link test with CLinker ${clinker.name}', () async {
      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();
      final testArchive = await buildTestArchive(
        tempUri,
        tempUri2,
        targetOS,
        targetArchitecture,
        androidTargetNdkApi: androidTargetNdkApi,
        macOSTargetVersion: macOSTargetVersion,
        iOSTargetVersion: iOSTargetVersion,
        iOSTargetSdk: iOSTargetSdk,
      );

      final linkInputBuilder = LinkInputBuilder()
        ..setupShared(
          packageName: 'testpackage',
          packageRoot: tempUri,
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: tempUri2,
        )
        ..setupLink(assets: [], recordedUsesFile: null)
        ..addExtension(
          CodeAssetExtension(
            targetOS: targetOS,
            targetArchitecture: targetArchitecture,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: cCompiler,
            android: androidTargetNdkApi != null
                ? AndroidCodeConfig(targetNdkApi: androidTargetNdkApi)
                : null,
            macOS: macOSTargetVersion != null
                ? MacOSCodeConfig(targetVersion: macOSTargetVersion)
                : null,
            iOS: iOSTargetVersion != null && iOSTargetSdk != null
                ? IOSCodeConfig(
                    targetSdk: iOSTargetSdk,
                    targetVersion: iOSTargetVersion,
                  )
                : null,
          ),
        );

      final linkInput = linkInputBuilder.build();
      final linkOutputBuilder = LinkOutputBuilder();

      printOnFailure(linkInput.config.code.cCompiler.toString());
      printOnFailure(Platform.environment.keys.toList().toString());
      await clinker
          .linker([testArchive.toFilePath()])
          .run(input: linkInput, output: linkOutputBuilder, logger: logger);

      final linkOutput = linkOutputBuilder.build();
      final asset = linkOutput.assets.code.first;

      await expectMachineArchitecture(
        asset.file!,
        targetArchitecture,
        targetOS,
      );

      final symbols = await readSymbols(asset, targetOS);
      final skipReason = symbols == null
          ? 'tool to extract symbols unavailable'
          : false;
      if (clinker.linker != linkerAutoKeepAll) {
        expect(symbols, contains('my_other_func'), skip: skipReason);
        expect(symbols, isNot(contains('my_func')), skip: skipReason);
      } else {
        expect(symbols, contains('my_other_func'), skip: skipReason);
        expect(symbols, contains('my_func'), skip: skipReason);
      }

      final sizeInBytes = await File.fromUri(asset.file!).length();
      // Make sure we don't override any results.
      expect(sizes[clinker.name], isNull);
      sizes[clinker.name] = sizeInBytes;
    });
    tearDownAll(() {
      expect(
        sizes['manual'],
        lessThan(sizes['autoEmpty']!),
        reason: 'Tree-shaking reduces size',
      );
      expect(
        sizes['auto'],
        lessThan(sizes['autoEmpty']!),
        reason: 'Tree-shaking reduces size',
      );
    });
  }
}
