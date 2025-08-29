// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'util.dart';

extension SwiftGenGenerator on SwiftGen {
  Future<void> generate(Logger logger) async {
    Directory(absTempDir).createSync(recursive: true);
    await _generateObjCFile();
    _generateDartFile(logger);
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

  void _generateDartFile(Logger logger) {
    fg.FfiGen(
      language: fg.Language.objc,
      output: ffigen.output,
      outputObjC: ffigen.outputObjC,
      wrapperName: ffigen.wrapperName ?? outModule,
      wrapperDocComment: ffigen.wrapperDocComment,
      preamble: ffigen.preamble,
      functionDecl: ffigen.functionDecl ?? fg.DeclarationFilters.excludeAll,
      structDecl: ffigen.structDecl ?? fg.DeclarationFilters.excludeAll,
      unionDecl: ffigen.unionDecl ?? fg.DeclarationFilters.excludeAll,
      enumClassDecl: ffigen.enumClassDecl ?? fg.DeclarationFilters.excludeAll,
      unnamedEnumConstants:
          ffigen.unnamedEnumConstants ?? fg.DeclarationFilters.excludeAll,
      globals: ffigen.globals ?? fg.DeclarationFilters.excludeAll,
      macroDecl: ffigen.macroDecl ?? fg.DeclarationFilters.excludeAll,
      typedefs: ffigen.typedefs ?? fg.DeclarationFilters.excludeAll,
      objcInterfaces: ffigen.objcInterfaces ?? fg.DeclarationFilters.excludeAll,
      objcProtocols: ffigen.objcProtocols ?? fg.DeclarationFilters.excludeAll,
      objcCategories: ffigen.objcCategories ?? fg.DeclarationFilters.excludeAll,
      entryPoints: [Uri.file(objcHeader)],
      compilerOpts: [
        ...fg.defaultCompilerOpts(logger),
        '-Wno-nullability-completeness',
      ],
      interfaceModuleFunc: (_) => outModule,
      protocolModuleFunc: (_) => outModule,
      externalVersions: ffigen.externalVersions,
    ).generate(logger: logger);
  }
}
