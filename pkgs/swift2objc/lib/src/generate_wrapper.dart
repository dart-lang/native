// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'config.dart';
import 'context.dart';
import 'generator/generator.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';
import 'utils.dart';

extension Swift2ObjCGeneratorMethod on Swift2ObjCGenerator {
  /// Used to generate the wrapper swift file.
  Future<void> generate({required Logger? logger}) => _generateWrapper(
    this,
    Context(logger ?? (Logger.detached('dev/null')..level = Level.OFF)),
  );
}

Future<void> _generateWrapper(
  Swift2ObjCGenerator config,
  Context context,
) async {
  final Directory tempDir;
  final bool deleteTempDirWhenDone;

  var lazyTarget = config.target;
  Future<String> target() async => lazyTarget ??= await hostTargetTriple;
  var lazySdkPath = config.sdk;
  Future<Uri> sdkPath() async => lazySdkPath ??= await hostSdk;

  if (config.tempDir == null) {
    tempDir = Directory.systemTemp.createTempSync(defaultTempDirPrefix);
    deleteTempDirWhenDone = true;
  } else {
    tempDir = Directory.fromUri(config.tempDir!);
    deleteTempDirWhenDone = false;
  }
  tempDir.createSync();

  final sourceModules = <String?>[];
  final mergedSymbolgraph = ParsedSymbolgraph();

  final allInputConfigs = [...config.inputs, builtInInputConfig];

  for (final input in allInputConfigs) {
    if (input is HasSymbolgraphCommand) {
      await _generateSymbolgraphJson(
        (input as HasSymbolgraphCommand).symbolgraphCommand(
          await target(),
          path.absolute((await sdkPath()).path),
        ),
        tempDir,
      );
    }

    final List<File> symbolgraphFiles;
    final String? mainFileName;
    switch (input) {
      case FilesInputConfig():
        mainFileName = '${input.tempModuleName}$symbolgraphFileSuffix';
        final prefix = '${input.tempModuleName}@';
        final files = tempDir.listSync().whereType<File>().where((f) {
          final name = path.basename(f.path);
          return name == mainFileName ||
              (name.startsWith(prefix) && name.endsWith(symbolgraphFileSuffix));
        }).toList()..sort((a, b) => a.path.compareTo(b.path));
        symbolgraphFiles = files.isNotEmpty
            ? files
            : [File(path.join(tempDir.path, mainFileName))];
      case ModuleInputConfig():
        mainFileName = '${input.module}$symbolgraphFileSuffix';
        final prefix = '${input.module}@';
        final files = tempDir.listSync().whereType<File>().where((f) {
          final name = path.basename(f.path);
          return name == mainFileName ||
              (name.startsWith(prefix) && name.endsWith(symbolgraphFileSuffix));
        }).toList()..sort((a, b) => a.path.compareTo(b.path));
        symbolgraphFiles = files.isNotEmpty
            ? files
            : [File(path.join(tempDir.path, mainFileName))];
      case JsonFileInputConfig():
        mainFileName = null;
        symbolgraphFiles = [File.fromUri(input.jsonFile)];
    }

    for (final file in symbolgraphFiles) {
      final symbolgraphJson = readJsonFile(file.path);
      final isMainFile =
          mainFileName == null || path.basename(file.path) == mainFileName;
      if (isMainFile) {
        sourceModules.add(switch (input) {
          FilesInputConfig() => null,
          ModuleInputConfig() => input.module,
          JsonFileInputConfig() => parseModuleName(symbolgraphJson),
        });
      }
      mergedSymbolgraph.merge(parseSymbolgraph(input, symbolgraphJson));
    }
  }

  final declarations = parseDeclarations(context, mergedSymbolgraph);
  final transformedDeclarations = transform(
    context,
    declarations,
    filter: config.include,
  );
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
