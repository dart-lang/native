// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart';
import 'generator/generator.dart';
import 'parser/_core/parsed_symbolgraph.dart';
import 'parser/_core/utils.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';
import 'utils.dart';

/// Used to generate the wrapper swift file.
Future<void> generateWrapper(Config config) async {
  final Directory tempDir;
  final bool deleteTempDirWhenDone;

  var lazyTarget = config.target;
  Future<String> target() async => lazyTarget ??= await hostTarget;
  var lazySdkPath = config.sdk;
  Future<Uri> sdkPath() async => lazySdkPath ??= await hostSdk;

  if (config.tempDir == null) {
    tempDir = Directory.systemTemp.createTempSync(defaultTempDirPrefix);
    deleteTempDirWhenDone = true;
  } else {
    tempDir = Directory.fromUri(config.tempDir!);
    deleteTempDirWhenDone = false;
  }

  final sourceModules = <String?>[];
  final mergedSymbolgraph = ParsedSymbolgraph();

  final allInputConfigs = [
    ModuleInputConfig(module: 'Foundation'),
    ...config.inputs,
  ];

  for (final input in allInputConfigs) {
    if (input.hasSymbolgraphCommand) {
      await _generateSymbolgraphJson(
        input.symbolgraphCommand(
            await target(), path.absolute((await sdkPath()).path)),
        tempDir,
      );
    }

    final symbolgraphFileName = switch (input) {
      FilesInputConfig() =>
        '${input.generatedModuleName}$symbolgraphFileSuffix',
      ModuleInputConfig() => '${input.module}$symbolgraphFileSuffix',
      JsonFileInputConfig() => path.absolute(input.jsonFile.path),
    };
    final symbolgraphJsonPath = path.join(tempDir.path, symbolgraphFileName);
    final symbolgraphJson = readJsonFile(symbolgraphJsonPath);

    sourceModules.add(switch (input) {
      FilesInputConfig() => null,
      ModuleInputConfig() => input.module,
      JsonFileInputConfig() => parseModuleName(symbolgraphJson),
    });
    mergedSymbolgraph.merge(parseSymbolgraph(symbolgraphJson));
  }

  final declarations = parseAst(mergedSymbolgraph);
  final transformedDeclarations =
      transform(declarations, filter: config.include);
  final wrapperCode = generate(
    transformedDeclarations,
    importedModuleNames: sourceModules.nonNulls.toList(),
    preamble: config.preamble,
  );

  File.fromUri(config.outputFile).writeAsStringSync(wrapperCode);

  if (deleteTempDirWhenDone) {
    tempDir.deleteSync(recursive: true);
  }
}

Future<void> _generateSymbolgraphJson(
  Command symbolgraphCommand,
  Directory workingDirectory,
) async {
  final result = await Process.run(
    symbolgraphCommand.executable,
    symbolgraphCommand.args,
    workingDirectory: workingDirectory.path,
  );

  if (result.exitCode != 0) {
    throw ProcessException(
      symbolgraphCommand.executable,
      symbolgraphCommand.args,
      'Error generating symbol graph \n${result.stdout} \n${result.stderr}',
    );
  }
}
