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

Future<void> main() async {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }
  const architecture = Architecture.x64;
  const os = OS.linux;
  const name = 'mylibname';

  final ldConfig = CCompilerConfig(linker: Uri.file('/usr/bin/ld'));
  final clangConfig = CCompilerConfig(linker: Uri.file('/usr/bin/clang'));
  for (final cCompilerConfig in [ldConfig, clangConfig]) {
    final linkerName = cCompilerConfig.linker!.pathSegments.last;
    test('link two objects with $linkerName', () async {
      final linkOutput = LinkOutput();
      final tempUri = await tempDirForTest();

      final linkConfig = LinkConfig(
        buildConfig: BuildConfig.build(
          outputDirectory: tempUri,
          packageName: 'testpackage',
          packageRoot: tempUri,
          targetArchitecture: architecture,
          targetOS: os,
          buildMode: BuildMode.debug,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompilerConfig,
        ),
        assetsForLinking: [],
        resourceIdentifierUri: null,
      );
      await CLinker(
              name: name,
              assetName: 'testassetname',
              linkerOptions: LinkerOptions.manual(gcSections: false),
              sources: [
                'test/clinker/testfiles/linker/test1.o',
                'test/clinker/testfiles/linker/test2.o',
              ].map((e) => packageUri.resolve(e).toFilePath()).toList())
          .run(
        linkConfig: linkConfig,
        linkOutput: linkOutput,
        logger: logger,
      );

      expect(linkOutput.assets, hasLength(1));
      final asset = linkOutput.assets.first;
      expect(asset, isA<NativeCodeAsset>());
      final file = (asset as NativeCodeAsset).file;
      expect(file, isNotNull, reason: 'Asset $asset has a file');
      final filePath = file!.toFilePath();
      expect(
        filePath,
        endsWith(os.dylibFileName(name)),
      );
      final readelf = (await runProcess(
        executable: Uri.file('readelf'),
        arguments: ['-WCs', filePath],
        logger: logger,
      ))
          .stdout;
      expect(readelf, contains('my_other_func'));
      expect(readelf, contains('my_func'));
    });
  }
}
