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
    fg.FfiGenerator(
      language: fg.Language.objc,
      output: fg.Output(
        dartFile: ffigen.output,
        objectiveCFile: ffigen.outputObjC,
        preamble: ffigen.preamble,
      ),
      bindingStyle: fg.DynamicLibraryBindings(
        wrapperName: ffigen.wrapperName ?? outModule,
        wrapperDocComment: ffigen.wrapperDocComment,
      ),
      functions: ffigen.functionDecl ?? fg.Functions.excludeAll,
      structs: ffigen.structDecl ?? fg.Structs.excludeAll,
      unions: ffigen.unionDecl ?? fg.Unions.excludeAll,
      enums: ffigen.enumClassDecl ?? fg.Enums.excludeAll,
      unnamedEnumConstants:
          ffigen.unnamedEnumConstants ?? fg.UnnamedEnums.excludeAll,
      globals: ffigen.globals ?? fg.DeclarationFilters.excludeAll,
      macroDecl: ffigen.macroDecl ?? fg.DeclarationFilters.excludeAll,
      typedefs: ffigen.typedefs ?? fg.Typedefs.excludeAll,
      objcInterfaces:
          ffigen.objcInterfaces ??
          fg.ObjCInterfaces(
            shouldInclude: (declaration) => false,
            module: (_) => outputModule,
          ),
      objcProtocols:
          ffigen.objcProtocols ??
          fg.ObjCProtocols(
            shouldInclude: (declaration) => false,
            module: (_) => outputModule,
          ),
      objcCategories: ffigen.objcCategories ?? fg.ObjCCategories.excludeAll,
      headers: fg.Headers(
        entryPoints: [Uri.file(objcHeader)],
        compilerOpts: [
          ...fg.defaultCompilerOpts(logger),
          '-Wno-nullability-completeness',
        ],
      ),
      externalVersions: ffigen.externalVersions,
    ).generate(logger: logger);
  }
}
