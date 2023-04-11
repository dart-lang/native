// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:c_compiler/c_compiler.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  final logger = Logger('')..level = Level.ALL;

  const targets = [
    Target.linuxArm,
    Target.linuxArm64,
    Target.linuxIA32,
    Target.linuxX64
  ];

  const readElfMachine = {
    Target.linuxArm: 'ARM',
    Target.linuxArm64: 'AArch64',
    Target.linuxIA32: 'Intel 80386',
    Target.linuxX64: 'Advanced Micro Devices X86-64',
  };

  for (final packaging in Packaging.values) {
    for (final target in targets) {
      test('Cbuilder $packaging library linux $target', () async {
        await inTempDir((tempUri) async {
          final packageUri = Directory.current.uri;
          final addCUri =
              packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
          final Uri libRelativeUri;
          if (packaging == Packaging.dynamic) {
            libRelativeUri = Uri.file('libadd.so');
          } else {
            libRelativeUri = Uri.file('libadd.a');
          }

          final buildConfig = BuildConfig(
            outDir: tempUri,
            packageRoot: tempUri,
            target: target,
            packaging: packaging == Packaging.dynamic
                ? PackagingPreference.dynamic
                : PackagingPreference.static,
          );

          final cbuilder = RunCBuilder(
            buildConfig: buildConfig,
            logger: logger,
            sources: [addCUri],
            dynamicLibrary:
                packaging == Packaging.dynamic ? libRelativeUri : null,
            staticLibrary:
                packaging == Packaging.static ? libRelativeUri : null,
          );
          await cbuilder.run();

          final libUri = tempUri.resolveUri(libRelativeUri);
          final result = await Process.run('readelf', ['-h', libUri.path]);
          expect(result.exitCode, 0);
          final machine = (result.stdout as String)
              .split('\n')
              .firstWhere((e) => e.contains('Machine:'));
          expect(machine, contains(readElfMachine[target]));
          expect(result.exitCode, 0);
        });
      });
    }
  }
}

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<void> inTempDir(
  Future<void> Function(Uri tempUri) fun, {
  String? prefix,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  try {
    await fun(tempDir.uri);
  } finally {
    if (!Platform.environment.containsKey(keepTempKey) ||
        Platform.environment[keepTempKey]!.isEmpty) {
      await tempDir.delete(recursive: true);
    }
  }
}
