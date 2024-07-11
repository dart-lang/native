// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/src/config/config.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

import 'test_util.dart';

String getClassNameFromPath(String path) {
  if (!path.endsWith('.java')) {
    throw ArgumentError('Filename must end with java');
  }
  return path
      .replaceAll('/', '.')
      .replaceAll('\\', '.')
      .substring(0, path.length - 5);
}

/// test/simple_package_test/java
final simplePackagePath = join('test', 'simple_package_test', 'java');

/// Directory(test/simple_package_test/java)
final simplePackageDir = Directory(simplePackagePath);

/// All Java files in simple_package_test/java
final javaFiles = findFilesWithSuffix(simplePackageDir, '.java');

/// All Java classes in simple_package_test/java
final javaClasses = javaFiles.map(getClassNameFromPath).toList();

// Remove individual class listings from one package,
// and add the package name instead, for testing.

const removalPackageForSummaryTests = 'com.github.dart_lang.jnigen.pkg2';

/// List of FQNs passed to summarizer for simple_package_test.
final summarizerClassesSpec = [
  ...javaClasses.where((e) => !e.startsWith('$removalPackageForSummaryTests.')),
  removalPackageForSummaryTests,
];

Config getSummaryGenerationConfig(
    {List<String>? sourcePath, List<String>? classPath}) {
  return Config(
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: Uri.file('unused.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
    // Make a defensive copy of class list, if some test mutates the list...
    classes: summarizerClassesSpec.toList(),
    sourcePath: sourcePath?.map(Uri.file).toList(),
    classPath: classPath?.map(Uri.file).toList(),
    logLevel: Level.WARNING,
  );
}

void deleteTempDirWithDelay(Directory directory) {
  try {
    if (Platform.isWindows) {
      // This appears to avoid "file used by another process" errors.
      sleep(const Duration(seconds: 1));
    }
    directory.deleteSync(recursive: true);
  } on FileSystemException catch (e) {
    log.warning('Cannot delete directory: $e');
  }
}
