// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/yaml_config.dart';
import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:ffigen/src/migration.dart' show migrate;
import 'package:package_config/package_config_types.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

String findOriginalPath(String fileName, String repoRoot, String ffigenRoot) {
  return path.join(ffigenRoot, 'test', 'migrate', 'yaml', fileName);
}

void _compareFiles(File expected, File actual) {
  if (!expected.existsSync()) {
    fail("Expected bindings file doesn't exist: ${expected.path}");
  }
  if (!actual.existsSync()) {
    fail("Actual generated file doesn't exist: ${actual.path}");
  }

  final diffResult = Process.runSync('git', [
    'diff',
    '--no-index',
    if (stderr.supportsAnsiEscapes) '--color=always',
    expected.path,
    actual.path,
  ]);
  if (diffResult.exitCode != 0) {
    fail(
      'Bindings generated from Dart script do not match expected YAML '
      'bindings:\n'
      '${diffResult.stdout}\n'
      '  ${expected.path}\n'
      '      vs\n'
      '  ${actual.path}',
    );
  }
}

String _resolveIncludePath(String opt, String configDir) {
  if (!opt.startsWith('-I')) return opt;
  final incPath = opt.substring(2);
  if (!path.isRelative(incPath)) return opt;

  final resolvedFromConfig = path.normalize(path.join(configDir, incPath));
  if (FileSystemEntity.typeSync(resolvedFromConfig) !=
      FileSystemEntityType.notFound) {
    return '-I$resolvedFromConfig';
  }
  final resolvedFromPackage = path.normalize(
    path.join(packagePathForTests, incPath),
  );
  if (FileSystemEntity.typeSync(resolvedFromPackage) !=
      FileSystemEntityType.notFound) {
    return '-I$resolvedFromPackage';
  }
  return opt;
}

Future<void> verifyMigration(
  File yamlFile, {
  bool Function(String expected, String actual)? dartVerify,
  bool Function(String expected, String actual)? objCVerify,
  bool Function(String expected, String actual)? cppVerify,
}) async {
  final testName = path.basenameWithoutExtension(yamlFile.path);
  final repoRoot = path.normalize(path.join(packagePathForTests, '..', '..'));
  final origConfigPath = findOriginalPath(
    path.basename(yamlFile.path),
    repoRoot,
    packagePathForTests,
  );

  final yamlContent = yamlFile.readAsStringSync();
  final yamlMap = yaml.loadYaml(yamlContent) as yaml.YamlMap;
  final logger = createTestLogger();
  final yamlConfig = YamlConfig.fromYaml(
    yamlMap,
    logger,
    filename: origConfigPath,
    packageConfig: PackageConfig([
      Package(
        'shared_bindings',
        Uri.file(
          path.join(packagePathForTests, 'example', 'shared_bindings', 'lib/'),
        ),
      ),
    ]),
  );

  final config = yamlConfig.configAdapter();
  final configDir = path.dirname(origConfigPath);
  final compilerOptions = config.input.compilerOptions;
  if (compilerOptions != null) {
    final newOptions = [
      for (final opt in compilerOptions) _resolveIncludePath(opt, configDir),
    ];
    compilerOptions
      ..clear()
      ..addAll(newOptions);
  }
  final context = testContext(config);
  final library = parse(context);

  // 1. Generate YAML bindings and verify against checked-in copy.
  final bindingsRelativeDir = ['test', 'migrate', 'bindings', testName];
  Directory(
    path.joinAll([packagePathForTests, ...bindingsRelativeDir]),
  ).createSync(recursive: true);

  final dartFileName = path.basename(config.output.dart.path.toFilePath());
  await matchLibraryWithExpected(
    context,
    library,
    path.join('bindings', testName, dartFileName),
    [...bindingsRelativeDir, dartFileName],
    format: config.output.format,
    verify: dartVerify,
    analyze: false,
  );

  final objCFileName = path.basename(config.output.objCFile.toFilePath());
  await matchFileWithExpected(
    context: context,
    pathForActual: path.join('bindings', testName, objCFileName),
    pathToExpected: [...bindingsRelativeDir, objCFileName],
    fileWriter: (File file, _) => library.generateObjCFile(
      file,
      headerPath: config.output.objCFile.toFilePath(),
    ),
    verify: objCVerify,
  );

  final cppFileName = path.basename(config.output.cppBindingsFile.toFilePath());
  await matchFileWithExpected(
    context: context,
    pathForActual: path.join('bindings', testName, cppFileName),
    pathToExpected: [...bindingsRelativeDir, cppFileName],
    fileWriter: (File file, _) => library.generateCppFile(
      file,
      headerPath: config.output.cppBindingsFile.toFilePath(),
    ),
    verify: cppVerify,
  );

  final symbolFile = config.output.symbolFile;
  if (symbolFile != null) {
    final symbolFileName = path.basename(symbolFile.output.toFilePath());
    await matchLibrarySymbolFileWithExpected(
      context,
      library,
      path.join('bindings', testName, symbolFileName),
      [...bindingsRelativeDir, symbolFileName],
      symbolFile.importPath.toString(),
    );
  }

  final recordUseMapping = config.output.recordUseMapping;
  if (recordUseMapping != null) {
    final recordUseFileName = path.basename(recordUseMapping.toFilePath());
    await matchRecordUseMappingWithExpected(
      context,
      library,
      path.join('bindings', testName, recordUseFileName),
      [...bindingsRelativeDir, recordUseFileName],
      format: config.output.format,
    );
  }

  // 2. Run YAML config through migrator and verify Dart script against
  // checked-in.
  final dartScriptRelativePath = ['test', 'migrate', 'dart', '$testName.dart'];
  final expectedDartScriptFile = File(
    path.joinAll([packagePathForTests, ...dartScriptRelativePath]),
  );
  expectedDartScriptFile.parent.createSync(recursive: true);

  await matchFileWithExpected(
    context: context,
    pathForActual: path.join('dart', '$testName.dart'),
    pathToExpected: dartScriptRelativePath,
    fileWriter: (File file, _) =>
        migrate(yamlConfig: yamlFile, outputDart: file),
  );

  // 3. Run the generated Dart script to generate bindings into target location.
  final scriptToRun = expectedDartScriptFile.existsSync()
      ? expectedDartScriptFile
      : File(path.join(context.tmpDir, 'dart', '$testName.dart'));

  final generatedDartFile = File(config.output.dart.path.toFilePath());
  final generatedObjCFile = File(config.output.objCFile.toFilePath());
  final generatedCppFile = File(config.output.cppBindingsFile.toFilePath());
  final generatedSymbolFile = config.output.symbolFile != null
      ? File(config.output.symbolFile!.output.toFilePath())
      : null;
  final generatedRecordUseFile = config.output.recordUseMapping != null
      ? File(config.output.recordUseMapping!.toFilePath())
      : null;

  final targetFiles = [
    generatedDartFile,
    generatedObjCFile,
    generatedCppFile,
    ?generatedSymbolFile,
    ?generatedRecordUseFile,
  ];

  try {
    final runResult = await Process.run(
      Platform.resolvedExecutable,
      ['run', scriptToRun.path],
      workingDirectory: packagePathForTests,
    );
    if (runResult.exitCode != 0) {
      fail(
        'Running Dart script ${scriptToRun.path} failed with exit code '
        '${runResult.exitCode}:\n'
        '${runResult.stderr}\n${runResult.stdout}',
      );
    }

    // 4. Verify bindings from YAML and from Dart script are the same.
    final checkedInBindingsDir = Directory(
      path.joinAll([packagePathForTests, ...bindingsRelativeDir]),
    );
    for (final expectedFile
        in checkedInBindingsDir.listSync().whereType<File>()) {
      final fileName = path.basename(expectedFile.path);
      final actualFile = targetFiles.firstWhere(
        (f) => path.basename(f.path) == fileName,
        orElse: () => File(
          path.join(
            path.dirname(config.output.dart.path.toFilePath()),
            fileName,
          ),
        ),
      );
      _compareFiles(expectedFile, actualFile);
    }
    for (final actualFile in targetFiles) {
      if (actualFile.existsSync()) {
        final fileName = path.basename(actualFile.path);
        final expectedFile = File(
          path.join(checkedInBindingsDir.path, fileName),
        );
        _compareFiles(expectedFile, actualFile);
      }
    }
  } finally {
    for (final file in targetFiles) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
