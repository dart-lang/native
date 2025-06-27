// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'util.dart';

extension _ConfigUtil on Config {
  String get absTempDir => p.absolute(tempDir.toFilePath());
  String get outModule => outputModule ?? input.module;
  String get objcHeader => p.join(absTempDir, '$outModule.h');
}

Future<void> generate(Config config) async {
  Directory(config.absTempDir).createSync(recursive: true);
  await _generateObjCFile(config);
  _generateDartFile(config);
}

Future<void> _generateObjCFile(Config config) => run('swiftc', [
  '-c',
  for (final uri in config.input.files) p.absolute(uri.toFilePath()),
  '-module-name',
  config.outModule,
  '-emit-objc-header-path',
  config.objcHeader,
  '-target',
  config.target.triple,
  '-sdk',
  p.absolute(config.target.sdk.toFilePath()),
  ...config.input.compileArgs,
], config.absTempDir);

void _generateDartFile(Config config) {
  final generator = ffigen.FfiGen(logLevel: Level.SEVERE);
  final ffigenConfig = ffigen.FfiGen(
    language: ffigen.Language.objc,
    output: config.ffigen.output,
    outputObjC: config.ffigen.outputObjC,
    wrapperName: config.ffigen.wrapperName ?? config.outModule,
    wrapperDocComment: config.ffigen.wrapperDocComment,
    preamble: config.ffigen.preamble,
    functionDecl:
        config.ffigen.functionDecl ?? ffigen.DeclarationFilters.excludeAll,
    structDecl:
        config.ffigen.structDecl ?? ffigen.DeclarationFilters.excludeAll,
    unionDecl: config.ffigen.unionDecl ?? ffigen.DeclarationFilters.excludeAll,
    enumClassDecl:
        config.ffigen.enumClassDecl ?? ffigen.DeclarationFilters.excludeAll,
    unnamedEnumConstants:
        config.ffigen.unnamedEnumConstants ??
        ffigen.DeclarationFilters.excludeAll,
    globals: config.ffigen.globals ?? ffigen.DeclarationFilters.excludeAll,
    macroDecl: config.ffigen.macroDecl ?? ffigen.DeclarationFilters.excludeAll,
    typedefs: config.ffigen.typedefs ?? ffigen.DeclarationFilters.excludeAll,
    objcInterfaces:
        config.ffigen.objcInterfaces ?? ffigen.DeclarationFilters.excludeAll,
    objcProtocols:
        config.ffigen.objcProtocols ?? ffigen.DeclarationFilters.excludeAll,
    entryPoints: [Uri.file(config.objcHeader)],
    compilerOpts: [
      ...ffigen.defaultCompilerOpts(),
      '-Wno-nullability-completeness',
    ],
    interfaceModuleFunc: (_) => config.outModule,
    protocolModuleFunc: (_) => config.outModule,
    externalVersions: config.ffigen.externalVersions,
  );
  generator.run(ffigenConfig);
}
