import 'dart:io';
import '../swift2objc.dart';
import 'config.dart';
import 'generator/generator.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';

void generateWrapperSync(Config config) {
  final parentDir = config.tempDir ?? defaultTempDir;
  final tempDir = parentDir.createTempSync(defaultTempDirPrefix);

  _generateSymbolgraphJsonSync(
    config.inputFiles,
    tempDir,
  );

  String? symbolgraphJsonPath;
  for (final entity in tempDir.listSync()) {
    if (entity is! File) continue;
    if (entity.path.endsWith(symbolgraphFileSuffix)) {
      symbolgraphJsonPath = entity.path;
      break;
    }
  }

  if (symbolgraphJsonPath == null) {
    throw Exception('Could not find generated symbolgraph json file.');
  }

  final declarations = parseAst(symbolgraphJsonPath);
  final transformedDeclarations = transform(declarations);
  final wrapperCode = generate(transformedDeclarations);

  File(config.outputFile).writeAsStringSync(wrapperCode);

  if (config.deleteTempAfterDone) {
    for (final entity in tempDir.listSync()) {
      entity.deleteSync();
    }
    tempDir.deleteSync();
  }
}

void _generateSymbolgraphJsonSync(
  List<String> inputFiles,
  Directory outputDirectory,
) {
  final result = Process.runSync(
    'swiftc',
    [
      ...inputFiles,
      '-emit-module',
      '-emit-symbol-graph',
      '-emit-symbol-graph-dir',
      '.',
    ],
    workingDirectory: outputDirectory.path,
  );

  if (result.exitCode != 0) {
    throw Exception(
      'Error generating symbol graph \n${result.stdout} \n${result.stderr}',
    );
  }
}
