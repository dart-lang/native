// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'ffigen_config.dart';
import 'util.dart';

extension SwiftGenGenerator on SwiftGen {
  Future<void> generate() async {
    Directory(absTempDir).createSync(recursive: true);
    await _generateObjCFile();
    _generateDartFile();
  }

  String get absTempDir => p.absolute(tempDir.toFilePath());
  String get outModule => outputModule ?? input.module;
  String get objcHeader => p.join(absTempDir, '$outModule.h');

  Future<void> _generateObjCFile() => run('swiftc', [
    '-c',
    for (final uri in input.files) p.absolute(uri.toFilePath()),
    '-module-name',
    outModule,
    '-emit-objc-header-path',
    objcHeader,
    '-target',
    target.triple,
    '-sdk',
    p.absolute(target.sdk.toFilePath()),
    ...input.compileArgs,
  ], absTempDir);

  void _generateDartFile() {
    final generator = fg.FfiGen(logLevel: Level.SEVERE);
    generator.run(
      FfiGenConfig(
        ffigen,
        [Uri.file(objcHeader)],
        [...fg.defaultCompilerOpts(), '-Wno-nullability-completeness'],
        outModule,
      ),
    );
  }
}
