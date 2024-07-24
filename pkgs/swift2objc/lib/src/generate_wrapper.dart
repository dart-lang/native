import 'dart:io';
import '../swift2objc.dart';
import 'config.dart';
import 'generator/generator.dart';
import 'parser/parser.dart';
import 'transformer/transform.dart';

Future<void> generateWrapper(Config config) async {
  final parentDir = config.tempDir ?? defaultTempDir;
  final tempDir = await parentDir.createTemp(defaultTempDirPrefix);

  await _generateSymbolgraphJson(
    config.inputFiles,
    tempDir,
  );

  String? symbolgraphJsonPath;
  await for (final entity in tempDir.list()) {
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

  await File(config.outputFile).writeAsString(wrapperCode);

  if (config.deleteTempAfterDone) {
    await for (final entity in tempDir.list()) {
      await entity.delete();
    }
    await tempDir.delete();
  }
}

Future<void> _generateSymbolgraphJson(
  List<String> inputFiles,
  Directory outputDirectory,
) async {
  final result = await Process.run(
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
