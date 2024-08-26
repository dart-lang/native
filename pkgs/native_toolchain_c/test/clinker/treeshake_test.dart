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

Future<void> main() async {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

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
  const architectures = [
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    Architecture.riscv64,
  ];

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
        );
        await clinker.linker([testArchive.toFilePath()]).run(
          config: config,
          output: linkOutput,
          logger: logger,
        );
        final filePath = linkOutput.assets.first.file!.toFilePath();

        final machine = await readelfMachine(filePath);
        expect(machine, contains(readElfMachine[architecture]));

        final symbols = await readelfSymbols(filePath);
        if (clinker.linker != linkerAutoEmpty) {
          expect(symbols, matches(r'[0-9]+\smy_other_func'));
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
