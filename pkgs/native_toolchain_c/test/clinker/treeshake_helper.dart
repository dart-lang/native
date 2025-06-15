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
  List<Architecture> architectures, {
  int? androidTargetNdkApi, // Must be specified iff targetOS is OS.android.
}) {
  assert((targetOS != OS.android) == (androidTargetNdkApi == null));
  CLinker linkerManual(List<String> sources) => CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: sources,
    linkerOptions: LinkerOptions.manual(
      flags: ['--strip-debug', '-u,my_other_func'],
      gcSections: true,
      linkerScript: packageUri.resolve(
        'test/clinker/testfiles/linker/symbols.lds',
      ),
    ),
  );
  CLinker linkerAuto(List<String> sources) => CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: sources,
    linkerOptions: LinkerOptions.treeshake(symbols: ['my_other_func']),
  );
  CLinker linkerAutoEmpty(List<String> sources) => CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: sources,
    linkerOptions: LinkerOptions.treeshake(symbols: null),
  );

  late Map<String, int> sizes;
  sizes = <String, int>{};
  for (final architecture in architectures) {
    for (final clinker in [
      (name: 'manual', linker: linkerManual),
      (name: 'auto', linker: linkerAuto),
      (name: 'autoEmpty', linker: linkerAutoEmpty),
    ]) {
      test('link test with CLinker ${clinker.name} and target '
          '$architecture for targetOS $targetOS', () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();
        final testArchive = await buildTestArchive(
          tempUri,
          tempUri2,
          targetOS,
          architecture,
          androidTargetNdkApi: androidTargetNdkApi,
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
              targetArchitecture: architecture,
              linkModePreference: LinkModePreference.dynamic,
              cCompiler: cCompiler,
              android: androidTargetNdkApi != null
                  ? AndroidCodeConfig(targetNdkApi: androidTargetNdkApi)
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

        await expectMachineArchitecture(asset.file!, architecture);

        final symbols = await nmReadSymbols(asset);
        if (clinker.linker != linkerAutoEmpty) {
          expect(symbols, contains('my_other_func'));
          expect(symbols, isNot(contains('my_func')));
        } else {
          expect(symbols, contains('my_other_func'));
          expect(symbols, contains('my_func'));
        }

        final sizeInBytes = await File.fromUri(asset.file!).length();
        sizes[clinker.name] = sizeInBytes;
      });
    }
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
