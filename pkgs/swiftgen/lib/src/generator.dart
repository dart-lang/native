// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:swift2objc/swift2objc.dart' as swift2objc;

import 'config.dart';
import 'util.dart';

extension SwiftGenGenerator on SwiftGenerator {
  Future<void> generate({required Logger? logger}) async {
    logger ??= Logger.detached('dev/null')..level = Level.OFF;
    Directory(absTempDir).createSync(recursive: true);
    final swift2objcConfigs = inputs
        .map((input) => input.swift2ObjCConfig)
        .nonNulls
        .toList();
    if (swift2objcConfigs.isNotEmpty) {
      await _generateObjCSwiftFile(swift2objcConfigs, logger);
    }
    await _generateObjCFile();
    _generateDartFile(logger);
  }

  String get absTempDir => p.absolute(tempDir.toFilePath());
  String get objcHeader => p.join(absTempDir, '$outputModule.h');

  Future<void> _generateObjCSwiftFile(
    List<swift2objc.InputConfig> swift2objcConfigs,
    Logger logger,
  ) => swift2objc.Swift2ObjCGenerator(
    inputs: swift2objcConfigs,
    include: include ?? (d) => true,
    outputFile: objcSwiftFile,
    tempDir: tempDir,
    preamble: objcSwiftPreamble,
  ).generate(logger: logger);

  Future<void> _generateObjCFile() => run('swiftc', [
    '-c',
    for (final input in inputs)
      for (final uri in input.files) p.absolute(uri.toFilePath()),
    p.absolute(objcSwiftFile.toFilePath()),
    '-module-name',
    outputModule,
    '-emit-objc-header-path',
    objcHeader,
    '-target',
    target.triple,
    '-sdk',
    p.absolute(target.sdk.toFilePath()),
  ], absTempDir);

  void _generateDartFile(Logger logger) {
    fg.FfiGenerator(
      output: fg.Output(
        dartFile: ffigen.output,
        objectiveCFile: ffigen.outputObjC,
        preamble: ffigen.preamble,
        style: fg.DynamicLibraryBindings(
          wrapperName: ffigen.wrapperName ?? outputModule,
          wrapperDocComment: ffigen.wrapperDocComment,
        ),
      ),

      functions: ffigen.functions,
      structs: ffigen.structs,
      unions: ffigen.unions,
      enums: ffigen.enums,
      unnamedEnums: ffigen.unnamedEnums,
      globals: ffigen.globals,
      integers: ffigen.integers,
      macros: ffigen.macros,
      typedefs: ffigen.typedefs,
      objectiveC: fg.ObjectiveC(
        interfaces: fg.Interfaces(
          include: ffigen.objectiveC.interfaces.include,
          includeMember: ffigen.objectiveC.interfaces.includeMember,
          includeSymbolAddress:
              ffigen.objectiveC.interfaces.includeSymbolAddress,
          rename: ffigen.objectiveC.interfaces.rename,
          renameMember: ffigen.objectiveC.interfaces.renameMember,
          includeTransitive: ffigen.objectiveC.interfaces.includeTransitive,
          module: (_) => outputModule,
        ),
        protocols: fg.Protocols(
          include: ffigen.objectiveC.protocols.include,
          includeMember: ffigen.objectiveC.protocols.includeMember,
          includeSymbolAddress:
              ffigen.objectiveC.protocols.includeSymbolAddress,
          rename: ffigen.objectiveC.protocols.rename,
          renameMember: ffigen.objectiveC.protocols.renameMember,
          includeTransitive: ffigen.objectiveC.protocols.includeTransitive,
          module: (_) => outputModule,
        ),
        categories: ffigen.objectiveC.categories,
        externalVersions: ffigen.objectiveC.externalVersions,
      ),
      headers: fg.Headers(
        entryPoints: [Uri.file(objcHeader)],
        compilerOptions: [
          ...fg.defaultCompilerOpts(logger),
          '-Wno-nullability-completeness',
        ],
      ),
    ).generate(logger: logger);
  }
}
