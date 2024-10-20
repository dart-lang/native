import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart';
import 'generator/generator.dart';
import 'parser/_core/utils.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';

/// Used to generate the wrapper swift file.
Future<void> generateWrapper(Config config) async {
  final Directory tempDir;
  final bool deleteTempDirWhenDone;

  if (config.tempDir == null) {
    tempDir = Directory.systemTemp.createTempSync(defaultTempDirPrefix);
    deleteTempDirWhenDone = true;
  } else {
    tempDir = Directory.fromUri(config.tempDir!);
    deleteTempDirWhenDone = false;
  }

  final input = config.input;

  await _generateSymbolgraphJson(
    input.symbolgraphCommand,
    tempDir,
  );

  final symbolgraphFileName = switch (input) {
    FilesInputConfig() => '${input.generatedModuleName}$symbolgraphFileSuffix',
    ModuleInputConfig() => '${input.module}$symbolgraphFileSuffix',
  };
  final symbolgraphJsonPath = path.join(tempDir.path, symbolgraphFileName);
  final symbolgraphJson = readJsonFile(symbolgraphJsonPath);

  final declarations = parseAst(symbolgraphJson);
  final transformedDeclarations = transform(declarations);
  
  final wrapperCode = generate(
    transformedDeclarations,
    moduleName:
        input is ModuleInputConfig ? praseModuleName(symbolgraphJson) : null,
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
