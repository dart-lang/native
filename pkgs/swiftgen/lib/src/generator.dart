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
  Future<void> generate({required Logger? logger, Uri? tempDirectory}) async {
    logger ??= Logger.detached('dev/null')..level = Level.OFF;
    tempDirectory ??= createTempDirectory();
    final absTempDir = p.absolute(tempDirectory.toFilePath());
    final objcHeader = p.join(absTempDir, '${output.module}.h');
    Directory(absTempDir).createSync(recursive: true);
    final swift2objcConfigs = inputs
        .map((input) => input.swift2ObjCConfig)
        .nonNulls
        .toList();
    if (swift2objcConfigs.isNotEmpty) {
      final swiftWrapperFile = output.swiftWrapperFile;
      if (swiftWrapperFile == null) {
        throw ArgumentError(
          'If any of the input Swift APIs require an Objective-C '
          'compatibility wrapper, output.swiftWrapperFile must not be null',
        );
      }
      await _generateObjCSwiftFile(
        swift2objcConfigs,
        logger,
        absTempDir,
        swiftWrapperFile,
      );
    }
    await _generateObjCFile(objcHeader, absTempDir, output.swiftWrapperFile);
    await _generateDartFile(logger, objcHeader);
  }

  Future<void> _generateObjCSwiftFile(
    List<swift2objc.InputConfig> swift2objcConfigs,
    Logger logger,
    String absTempDir,
    SwiftWrapperFile swiftWrapperFile,
  ) => swift2objc.Swift2ObjCGenerator(
    inputs: swift2objcConfigs,
    include: include,
    outputFile: swiftWrapperFile.path,
    tempDir: Uri.directory(absTempDir),
    preamble: swiftWrapperFile.preamble,
    target: target.triple,
    sdk: target.sdk,
  ).generate(logger: logger);

  Future<void> _generateObjCFile(
    String objcHeader,
    String absTempDir,
    SwiftWrapperFile? swiftWrapperFile,
  ) => run('swiftc', [
    '-c',
    for (final input in inputs)
      for (final uri in input.files) p.absolute(uri.toFilePath()),
    if (swiftWrapperFile != null)
      p.absolute(swiftWrapperFile.path.toFilePath()),
    '-module-name',
    output.module,
    '-emit-objc-header-path',
    objcHeader,
    '-target',
    target.triple,
    '-sdk',
    p.absolute(target.sdk.toFilePath()),
  ], absTempDir);

  Future<void> _generateDartFile(Logger logger, String objcHeader) async {
    final generator = fg.FfiGenerator(
      output: fg.Output(
        dart: fg.DartCodeOutput(path: output.dartFile),
        objectiveCFile: output.objectiveCFile,
        preamble: output.preamble ?? '',
        style: fg.NativeExternalBindings(assetId: output.assetId),
      ),
      objectiveC: fg.ObjectiveC(
        externalVersions: ffigen.objectiveC.externalVersions,
      ),
      visitors: [
        ...ffigen.visitors,
        fg.Visitor(
          objCInterface: (node) => node.module ??= output.module,
          objCProtocol: (node) => node.module ??= output.module,
        ),
      ],
      input: fg.Input(
        entryPoints: [Uri.file(objcHeader)],
        compilerOptions: [
          ...fg.defaultCompilerOpts(logger),
          '-Wno-nullability-completeness',
        ],
      ),
    );
    await generator.generate(logger: logger);
  }
}
