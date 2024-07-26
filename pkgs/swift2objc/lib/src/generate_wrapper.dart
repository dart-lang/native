import 'dart:io';

import 'package:path/path.dart' as path;

import 'config.dart';
import 'generator/generator.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';

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

  await _generateSymbolgraphJson(
    config.inputFiles,
    tempDir,
    config.moduleName,
  );

  final symbolgraphFileName = '${config.moduleName}$symbolgraphFileSuffix';
  final symbolgraphJsonPath = path.join(tempDir.path, symbolgraphFileName);

  final declarations = parseAst(symbolgraphJsonPath);
  final transformedDeclarations = transform(declarations);
  final wrapperCode = generate(transformedDeclarations);

  File.fromUri(config.outputFile).writeAsStringSync(wrapperCode);

  if (deleteTempDirWhenDone) {
    tempDir.deleteSync(recursive: true);
  }
}

Future<void> _generateSymbolgraphJson(
  List<Uri> inputFiles,
  Directory outputDirectory,
  String moduleName,
) async {
  final result = await Process.run(
    'swiftc',
    [
      ...inputFiles.map((uri) => path.absolute(uri.path)),
      '-emit-module',
      '-emit-symbol-graph',
      '-emit-symbol-graph-dir',
      '.',
      '-module-name',
      moduleName
    ],
    workingDirectory: outputDirectory.path,
  );

  if (result.exitCode != 0) {
    throw Exception(
      'Error generating symbol graph \n${result.stdout} \n${result.stderr}',
    );
  }
}
