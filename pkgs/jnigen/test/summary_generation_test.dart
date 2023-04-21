// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These tests validate summary generation in various scenarios.
// Currently, no validation of the summary content itself is done.

@Tags(['summarizer_test'])

import 'dart:io';

import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/elements/elements.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/summary/summary.dart';
import 'package:logging/logging.dart';

import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void expectNonEmptySummary(Classes? classes) {
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

List<String> findFiles(Directory dir, String suffix) {
  return dir
      .listSync(recursive: true)
      .map((entry) => relative(entry.path, from: dir.path))
      .where((path) => path.endsWith(suffix))
      .toList();
}

/// Packs files indicated by [artifacts], each relative to [artifactDir] into
/// a JAR file at [jarPath].
Future<void> createJar({
  required String artifactDir,
  required List<String> artifacts,
  required String jarPath,
}) async {
  final status = await runCommand(
    'jar',
    ['cf', relative(jarPath, from: artifactDir), ...artifacts],
    workingDirectory: artifactDir,
  );
  if (status != 0) {
    throw ArgumentError('Cannot create JAR from provided arguments');
  }
}

Future<void> compileJavaFiles(List<String> paths, Directory target) async {
  final status = await runCommand(
    'javac',
    ['-d', target.absolute.path, ...paths],
    workingDirectory: simplePackagePath,
  );
  if (status != 0) {
    throw ArgumentError('Cannot compile Java sources');
  }
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
final javaFiles = findFiles(simplePackageDir, '.java');
final javaClasses = javaFiles.map(getClassNameFromPath).toList();

Config getConfig({List<String>? sourcePath, List<String>? classPath}) {
  return Config(
    outputConfig: OutputConfig(
      bindingsType: BindingsType.dartOnly,
      dartConfig: DartCodeOutputConfig(
        path: Uri.file('unused.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    classes: javaClasses,
    sourcePath: sourcePath?.map((e) => Uri.file(e)).toList(),
    classPath: classPath?.map((e) => Uri.file(e)).toList(),
    logLevel: Level.WARNING,
  );
}

void main() async {
  await checkLocallyBuiltDependencies();
  late Directory tempDir;
  setUpAll(() async {
    tempDir = getTempDir("jnigen_summary_tests_");
  });

  test('Test summary generation from compiled JAR', () async {
    final targetDir = tempDir.createTempSync("compiled_jar_test_");
    await compileJavaFiles(javaFiles, targetDir);
    final classFiles = findFiles(targetDir, '.class');
    final jarPath = join(targetDir.absolute.path, 'classes.jar');
    await createJar(
        artifactDir: targetDir.path, artifacts: classFiles, jarPath: jarPath);
    final config = getConfig(classPath: [jarPath]);
    final summaryClasses = await getSummary(config);
    expectNonEmptySummary(summaryClasses);
  });

  test('Test summary generation from source JAR', () async {
    final targetDir = tempDir.createTempSync("source_jar_test_");
    final jarPath = join(targetDir.path, 'sources.jar');
    await createJar(
        artifactDir: simplePackageDir.path,
        artifacts: javaFiles,
        jarPath: jarPath);
    final config = getConfig(sourcePath: [jarPath]);
    final summaryClasses = await getSummary(config);
    expectNonEmptySummary(summaryClasses);
  });

  test('Test summary generation from source folder', () async {
    final config = getConfig(sourcePath: [simplePackagePath]);
    final summaryClasses = await getSummary(config);
    expectNonEmptySummary(summaryClasses);
  });

  test('Test summary generation from compiled classes in directory', () async {
    final targetDir = tempDir.createTempSync("compiled_classes_test_");
    await compileJavaFiles(javaFiles, targetDir);
    final config = getConfig(classPath: [targetDir.path]);
    final summaryClasses = await getSummary(config);
    expectNonEmptySummary(summaryClasses);
  });

  // Test summary generation from combination of a source and class path
  test('Test summary generation from combination', () async {
    final targetDir = tempDir.createTempSync("combination_test_");

    // remove a class from source files and create a source JAR
    final sourceFiles = javaFiles.toList();
    sourceFiles.removeLast();
    final sourceJarPath = join(targetDir.path, 'sources.jar');
    await createJar(
      artifactDir: simplePackageDir.path,
      artifacts: sourceFiles,
      jarPath: sourceJarPath,
    );

    await compileJavaFiles(javaFiles, targetDir);
    final classFiles = findFiles(targetDir, '.class');
    final classesJarPath = join(targetDir.path, 'classes.jar');
    await createJar(
      artifactDir: targetDir.path,
      artifacts: classFiles,
      jarPath: classesJarPath,
    );
    final config = getConfig(
      classPath: [classesJarPath],
      sourcePath: [sourceJarPath],
    );
    final summaryClasses = await getSummary(config);
    expectNonEmptySummary(summaryClasses);
  });

  tearDownAll(() => deleteTempDir(tempDir));
}
