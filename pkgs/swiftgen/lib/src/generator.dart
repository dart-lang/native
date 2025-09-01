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
        bindingStyle: fg.DynamicLibraryBindings(
          wrapperName: ffigen.wrapperName ?? outModule,
          wrapperDocComment: ffigen.wrapperDocComment,
        ),
      ),

      functions: ffigen.functions ?? fg.Functions.excludeAll,
      structs: ffigen.structs ?? fg.Structs.excludeAll,
      unions: ffigen.unions ?? fg.Unions.excludeAll,
      enums: ffigen.enums ?? fg.Enums.excludeAll,
      unnamedEnums: ffigen.unnamedEnums ?? fg.UnnamedEnums.excludeAll,
      globals: ffigen.globals ?? fg.Declarations.excludeAll,
      macros: ffigen.macros ?? fg.Declarations.excludeAll,
      typedefs: ffigen.typedefs ?? fg.Typedefs.excludeAll,
      objectiveC: fg.ObjectiveC(
        interfaces:
            ffigen.objcInterfaces ??
            fg.ObjCInterfaces(
              shouldInclude: (declaration) => false,
              module: (_) => outputModule,
            ),
        protocols:
            ffigen.objcProtocols ??
            fg.ObjCProtocols(
              shouldInclude: (declaration) => false,
              module: (_) => outputModule,
            ),
        categories: ffigen.objcCategories ?? fg.ObjCCategories.excludeAll,

        externalVersions: ffigen.externalVersions,
      ),
      headers: fg.Headers(
        entryPoints: [Uri.file(objcHeader)],
        compilerOpts: [
          ...fg.defaultCompilerOpts(logger),
          '-Wno-nullability-completeness',
        ],
      ),
    ).generate(logger: logger);
  }
}
