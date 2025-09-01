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
      language: fg.Language.objc,
      output: ffigen.output,
      outputObjC: ffigen.outputObjC,
      wrapperName: ffigen.wrapperName ?? outputModule,
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
      interfaceModule: (_) => outputModule,
      protocolModule: (_) => outputModule,
      externalVersions: ffigen.externalVersions,
    ).generate(logger: logger);
  }
}
