// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//TODO(mosuem): Enable for windows and mac.
// See https://github.com/dart-lang/native/issues/1376.
@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'build_testfiles.dart';

Future<void> runTests(List<Architecture> architectures) async {
  CLinker linkerManual(List<String> sources) => CLinker.library(
        name: 'mylibname',
        assetName: '',
        sources: sources,
        linkerOptions: LinkerOptions.manual(
          flags: ['--strip-debug', '-u', 'my_other_func'],
          gcSections: true,
          linkerScript:
              packageUri.resolve('test/clinker/testfiles/linker/symbols.lds'),
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

  const os = OS.linux;

  late Map<String, int> sizes;
  sizes = <String, int>{};
  for (final architecture in architectures) {
    for (final clinker in [
      (name: 'manual', linker: linkerManual),
      (name: 'auto', linker: linkerAuto),
      (name: 'autoEmpty', linker: linkerAutoEmpty),
    ]) {
      test('link test with CLinker ${clinker.name} and target $architecture',
          () async {
        final tempUri = await tempDirForTest();
        final testArchive = await buildTestArchive(tempUri, os, architecture);

        final linkOutput = LinkOutput();

        final config = LinkConfig.build(
          outputDirectory: tempUri,
          packageName: 'testpackage',
          packageRoot: tempUri,
          targetArchitecture: architecture,
          targetOS: os,
          buildMode: BuildMode.release,
          linkModePreference: LinkModePreference.dynamic,
          assets: [],
          cCompiler: cCompiler,
        );
        printOnFailure(config.cCompiler.toString());
        printOnFailure(Platform.environment.keys.toList().toString());
        await clinker.linker([testArchive.toFilePath()]).run(
          config: config,
          output: linkOutput,
          logger: logger,
        );

        final asset = linkOutput.assets.first as NativeCodeAsset;
        final filePath = asset.file!.toFilePath();

        final machine = await readelfMachine(filePath);
        expect(machine, contains(readElfMachine[architecture]));

        final symbols = await nmReadSymbols(asset);
        if (clinker.linker != linkerAutoEmpty) {
          expect(symbols, contains('my_other_func'));
          expect(symbols, isNot(contains('my_func')));
        } else {
          expect(symbols, contains('my_other_func'));
          expect(symbols, contains('my_func'));
        }

        final du = Process.runSync('du', ['-sb', filePath]).stdout as String;
        final sizeInBytes = int.parse(du.split('\t')[0]);
        sizes[clinker.name] = sizeInBytes;
      });
    }
    tearDownAll(
      () {
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
      },
    );
  }
}
