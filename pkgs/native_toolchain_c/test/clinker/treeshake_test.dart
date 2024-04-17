// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final sources = [
    packageUri.resolve('test/clinker/testfiles/linker/test.a').toFilePath()
  ];
  final linkerManual = CLinker(
    name: 'mylibname',
    assetName: 'assetName',
    sources: sources,
    linkerOptions: LinkerOptions.manual(
      flags: ['--strip-debug', '-u', 'my_other_func'],
      gcSections: true,
      linkerScript: Uri.file('test/clinker/testfiles/linker/symbols.lds'),
    ),
  );
  final linkerAuto = CLinker(
    name: 'mylibname',
    assetName: 'assetName',
    sources: sources,
    linkerOptions: LinkerOptions.treeshake(symbols: ['my_other_func']),
  );
  final linkerAutoEmpty = CLinker(
    name: 'mylibname',
    assetName: 'assetName',
    sources: sources,
    linkerOptions: LinkerOptions.treeshake(symbols: null),
  );
  const architecture = Architecture.x64;
  const os = OS.linux;

  final ldConfig = CCompilerConfig(linker: Uri.file('/usr/bin/ld'));
  final clangConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));
  for (final clinker in [
    (name: 'manual', linkerManual),
    (name: 'auto', linkerAuto),
    (name: 'autoEmpty', linkerAutoEmpty),
  ]) {
    for (final compiler in [
      (config: ldConfig, maxSize: 13760),
      (config: clangConfig, maxSize: 15457),
    ]) {
      final linkerName = compiler.config.linker!.pathSegments.last;
      test('link test $linkerName with ${clinker.name}', () async {
        final tempUri = await tempDirForTest();
        final linkOutput = LinkOutput();

        final config = LinkConfig(
          resourceIdentifierUri: null,
          buildConfig: BuildConfig.build(
            outputDirectory: tempUri,
            packageName: 'testpackage',
            packageRoot: tempUri,
            targetArchitecture: architecture,
            targetOS: os,
            buildMode: BuildMode.release,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: compiler.config,
          ),
          assetsForLinking: [],
        );
        await clinker.$1.run(
          linkConfig: config,
          linkOutput: linkOutput,
          logger: logger,
        );
        final (readelf, sizeInBytes) = await elfAndSize(linkOutput);
        if (clinker.$1 != linkerAutoEmpty) {
          expect(readelf, matches(r'[0-9]+\smy_other_func'));
          expect(readelf, isNot(contains('my_func')));

          expect(sizeInBytes, lessThan(compiler.maxSize));
        } else {
          expect(readelf, contains('my_other_func'));
          expect(readelf, contains('my_func'));
        }
      });
    }
  }
}

Future<(String, int)> elfAndSize(LinkOutput linkOutput) async {
  final filePath = linkOutput.assets.first.file!.toFilePath();

  final readelf = (await runProcess(
    executable: Uri.file('readelf'),
    arguments: ['-WCs', filePath],
    logger: logger,
  ))
      .stdout;

  final du = Process.runSync('du', ['-sb', filePath]).stdout as String;
  final sizeInBytes = int.parse(du.split('\t')[0]);

  return (readelf, sizeInBytes);
}
