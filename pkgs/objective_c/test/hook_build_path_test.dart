// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as hook;

void main() {
  test(
    'build hook decodes percent-encoded package root paths',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'objective_c_hook_path',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final realPackageRoot = findPackageRoot('objective_c');
      const rootDirName = 'pkg%47root';
      final rootDir = Directory('${tempDir.path}/$rootDirName');
      await rootDir.create();
      final symlinkPath = '${rootDir.path}/objective_c';
      await Link(symlinkPath).create(realPackageRoot.toFilePath());
      final symlinkDir = Directory(symlinkPath);

      final encodedPath = symlinkPath.replaceAll('%', '%25');
      final encodedPackageRoot = Uri.parse(
        'file:///${encodedPath.substring(1)}/',
      );
      expect(encodedPackageRoot.toString(), contains('%2547'));

      final compilerLog = tempDir.uri
          .resolve('compiler_args.txt')
          .toFilePath();
      File(compilerLog).writeAsStringSync('');
      final compilerScript = tempDir.uri.resolve('clang').toFilePath();
      File(compilerScript).writeAsStringSync('''#!/bin/sh
if [ "\$1" = "--version" ]; then
  echo "Apple clang version 15.0.0"
  exit 0
fi
log="$compilerLog"
out=""
prev=""
for arg in "\$@"; do
  if [ "\$prev" = "-o" ]; then
    out="\$arg"
  fi
  prev="\$arg"
  printf '%s\\n' "\$arg" >> "\$log"
done
if [ -n "\$out" ]; then
  mkdir -p "\$(dirname "\$out")"
  : > "\$out"
fi
exit 0
''');
      Process.runSync('chmod', ['+x', compilerScript]);

      final outputDirectoryShared = tempDir.uri.resolve('output_shared/');
      await Directory.fromUri(outputDirectoryShared).create();
      final outputFile = tempDir.uri.resolve('output.json');

      final inputBuilder = BuildInputBuilder()
        ..setupShared(
          packageRoot: encodedPackageRoot,
          packageName: 'objective_c',
          outputFile: outputFile,
          outputDirectoryShared: outputDirectoryShared,
        )
        ..setupBuildInput()
        ..config.setupBuild(linkingEnabled: false)
        ..addExtension(
          CodeAssetExtension(
            targetArchitecture: Architecture.current,
            targetOS: OS.macOS,
            linkModePreference: LinkModePreference.dynamic,
            macOS: MacOSCodeConfig(targetVersion: 13),
            cCompiler: CCompilerConfig(
              compiler: Uri.file(compilerScript),
              linker: Uri.file(compilerScript),
              archiver: Uri.file(compilerScript),
            ),
          ),
        );
      final input = inputBuilder.build();
      final inputFile = tempDir.uri.resolve('input.json');
      File.fromUri(inputFile).writeAsStringSync(json.encode(input.json));

      final originalCwd = Directory.current;
      Directory.current = symlinkDir;
      try {
        await (hook.main as dynamic)(['--config=${inputFile.toFilePath()}']);
      } finally {
        Directory.current = originalCwd;
      }

      final logLines = File(compilerLog).readAsLinesSync();
      final decodedUtil = '$symlinkPath/test/util.c';
      expect(logLines, contains(decodedUtil));
      expect(logLines.any((line) => line.contains('%2547')), isFalse);
    },
    skip: !Platform.isMacOS ? 'Requires macOS' : null,
  );
}
