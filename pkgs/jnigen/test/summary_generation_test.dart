// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These tests validate summary generation in various scenarios.
// Currently, no validation of the summary content itself is done.

@Tags(['summarizer_test'])

import 'dart:io';
import 'dart:math';

import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/summary/summary.dart';
import 'package:logging/logging.dart';

import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void expectSummaryHasAllClasses(Classes? classes) {
  expect(classes, isNotNull);
  final decls = classes!.decls;
  expect(decls.entries.length, greaterThanOrEqualTo(javaFiles.length));
  final declNames = decls.keys.toSet();
  final expectedClasses =
      javaClasses.where((name) => !name.contains("annotations.")).toList();
  expect(declNames, containsAll(expectedClasses));
}

void deleteTempDir(Directory directory) {
  try {
    if (Platform.isWindows) {
      // This appears to avoid "file used by another process" errors.
      sleep(const Duration(seconds: 1));
    }
    directory.deleteSync(recursive: true);
  } on FileSystemException catch (e) {
    log.warning("Cannot delete directory: $e");
  }
}

/// Packs files indicated by [artifacts], each relative to [artifactDir] into
/// a JAR file at [jarPath].
Future<void> createJar({
  required String artifactDir,
  required List<String> artifacts,
  required String jarPath,
}) async {
  await runCommand(
    'jar',
    ['cf', relative(jarPath, from: artifactDir), ...artifacts],
    workingDirectory: artifactDir,
  );
}

String getClassNameFromPath(String path) {
  if (!path.endsWith('.java')) {
    throw ArgumentError('Filename must end with java');
  }
  return path
      .replaceAll('/', '.')
      .replaceAll('\\', '.')
      .substring(0, path.length - 5);
}

final simplePackagePath = join('test', 'simple_package_test', 'java');
final simplePackageDir = Directory(simplePackagePath);
final javaFiles = findFilesWithSuffix(simplePackageDir, '.java');
final javaClasses = javaFiles.map(getClassNameFromPath).toList();
// remove individual class listings from one package,
// and add the package name instead, for testing.
const _removalPackage = 'com.github.dart_lang.jnigen.pkg2';
final summarizerClassesSpec = [
  ...javaClasses.where((e) => !e.startsWith('$_removalPackage.')),
  _removalPackage,
];

Config getConfig({List<String>? sourcePath, List<String>? classPath}) {
  return Config(
    outputConfig: OutputConfig(
      bindingsType: BindingsType.dartOnly,
      dartConfig: DartCodeOutputConfig(
        path: Uri.file('unused.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    classes: summarizerClassesSpec,
    sourcePath: sourcePath?.map((e) => Uri.file(e)).toList(),
    classPath: classPath?.map((e) => Uri.file(e)).toList(),
    logLevel: Level.WARNING,
  );
}

final random = Random.secure();

void testSuccessCase(String description, Config config) {
  config.classes = summarizerClassesSpec;
  test(description, () async {
    final classes = await getSummary(config);
    expectSummaryHasAllClasses(classes);
  });
}

void testFailureCase(
    String description, Config config, String nonExistingClass) {
  test(description, () async {
    final insertPosition = random.nextInt(config.classes.length + 1);
    config.classes = summarizerClassesSpec.sublist(0, insertPosition) +
        [nonExistingClass] +
        summarizerClassesSpec.sublist(insertPosition);
    try {
      await getSummary(config);
    } on SummaryParseException catch (e) {
      expect(e.stderr, isNotNull);
      expect(e.stderr!, stringContainsInOrder(["Not found", nonExistingClass]));
      return;
    }
    throw AssertionError("No exception was caught");
  });
}

void testAllCases({
  List<String>? sourcePath,
  List<String>? classPath,
}) {
  testSuccessCase(
    '- valid config',
    getConfig(sourcePath: sourcePath, classPath: classPath),
  );
  testFailureCase(
    '- should fail with non-existing class',
    getConfig(sourcePath: sourcePath, classPath: classPath),
    'com.github.dart_lang.jnigen.DoesNotExist',
  );
  testFailureCase(
    '- should fail with non-existing package',
    getConfig(sourcePath: sourcePath, classPath: classPath),
    'com.github.dart_lang.notexist',
  );
}

void main() async {
  await checkLocallyBuiltDependencies();
  final tempDir = getTempDir("jnigen_summary_tests_");

  group('Test summary generation from compiled JAR', () {
    final targetDir = tempDir.createTempSync("compiled_jar_test_");
    final jarPath = join(targetDir.absolute.path, 'classes.jar');
    setUpAll(() async {
      await compileJavaFiles(simplePackageDir, targetDir);
      final classFiles = findFilesWithSuffix(targetDir, '.class');
      await createJar(
          artifactDir: targetDir.path, artifacts: classFiles, jarPath: jarPath);
    });
    testAllCases(classPath: [jarPath]);
  });

  group('Test summary generation from source JAR', () {
    final targetDir = tempDir.createTempSync("source_jar_test_");
    final jarPath = join(targetDir.path, 'sources.jar');
    setUpAll(() async {
      await createJar(
          artifactDir: simplePackageDir.path,
          artifacts: javaFiles,
          jarPath: jarPath);
    });
    testAllCases(sourcePath: [jarPath]);
  });

  group('Test summary generation from source folder', () {
    testAllCases(sourcePath: [simplePackagePath]);
  });

  group('Test summary generation from compiled classes in directory', () {
    final targetDir = tempDir.createTempSync("compiled_classes_test_");
    setUpAll(() => compileJavaFiles(simplePackageDir, targetDir));
    testAllCases(classPath: [targetDir.path]);
  });

  // Test summary generation from combination of a source and class path
  group('Test summary generation from combination', () {
    final targetDir = tempDir.createTempSync("combination_test_");
    final classesJarPath = join(targetDir.path, 'classes.jar');
    // remove a class from source files and create a source JAR
    final sourceFiles = javaFiles.toList();
    sourceFiles.removeLast();
    final sourceJarPath = join(targetDir.path, 'sources.jar');
    setUpAll(() async {
      await createJar(
        artifactDir: simplePackageDir.path,
        artifacts: sourceFiles,
        jarPath: sourceJarPath,
      );

      await compileJavaFiles(simplePackageDir, targetDir);
      final classFiles = findFilesWithSuffix(targetDir, '.class');
      await createJar(
        artifactDir: targetDir.path,
        artifacts: classFiles,
        jarPath: classesJarPath,
      );
    });
    testAllCases(
      classPath: [classesJarPath],
      sourcePath: [sourceJarPath],
    );
  });

  tearDownAll(() => deleteTempDir(tempDir));
}
