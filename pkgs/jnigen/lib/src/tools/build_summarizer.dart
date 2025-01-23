// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(#43): Address concurrently building summarizer.
//
// In the current state summarizer has to be built before tests, which run
// concurrently. Ignoring coverage for this file until that issue is addressed.
//
// coverage:ignore-file

import 'dart:io';

import 'package:path/path.dart';

import '../logging/logging.dart';
import '../util/find_package.dart';

final toolPath = join('.', '.dart_tool', 'jnigen');
final mvnTargetDir = join(toolPath, 'target');
final gradleBuildDir = join('java', 'build');
final gradleTargetDir = join(gradleBuildDir, 'libs');
final jarFile = join(gradleTargetDir, 'ApiSummarizer.jar');
final targetJarFile = join(toolPath, 'ApiSummarizer.jar');

Future<void> buildApiSummarizer() async {
  final pkg = await findPackageRoot('jnigen');
  if (pkg == null) {
    log.fatal('package jnigen not found!');
  }
  final gradleFile = pkg.resolve('java/build.gradle.kts');
  // TODO will be a problem if using windows.
  // TODO Windows uses gradlew.bat
  final gradleWrapper = pkg.resolve('gradlew');
  await Directory(toolPath).create(recursive: true);
  final gradleArgs = [
    '-b',
    gradleFile.toFilePath(),
    'buildFatJar',       // from ktor plugin
    '-x', 'test'   // ignore failing tests
  ];
  log.info('execute gradlew ${gradleFile}');
  try {
    final gradleProc = await Process.run(gradleWrapper.toFilePath(), gradleArgs,
        workingDirectory: toolPath, runInShell: true);
    final exitCode = gradleProc.exitCode;
    log.info("exit code: $exitCode");
    if (exitCode == 0) {
      File(jarFile).copySync(targetJarFile);
    } else {
      printError(gradleProc.stdout);
      printError(gradleProc.stderr);
      printError('gradle exited with $exitCode');
    }
  } finally {
    // Remove build directory
    await Directory(gradleBuildDir).delete(recursive: true);
  }
}

Future<void> buildApiSummarizer2() async {
  final pkg = await findPackageRoot('jnigen');
  if (pkg == null) {
    log.fatal('package jnigen not found!');
  }
  final pom = pkg.resolve('java/pom.xml');
  await Directory(toolPath).create(recursive: true);
  final mvnArgs = [
    'compile',
    '--batch-mode',
    '--update-snapshots',
    '-f',
    pom.toFilePath(),
  ];
  log.info('execute mvn ${mvnArgs.join(" ")}');
  try {
    final mvnProc = await Process.run('mvn', mvnArgs,
        workingDirectory: toolPath, runInShell: true);
    final exitCode = mvnProc.exitCode;
    if (exitCode == 0) {
      await File(targetJarFile).rename(jarFile);
    } else {
      printError(mvnProc.stdout);
      printError(mvnProc.stderr);
      printError('maven exited with $exitCode');
    }
  } finally {
    await Directory(mvnTargetDir).delete(recursive: true);
  }
}

Future<void> buildSummarizerIfNotExists({bool force = false}) async {
  // TODO(#43): This function cannot be invoked concurrently because 2 processes
  // will start building summarizer at once. Introduce a locking mechnanism so
  // that when one process is building summarizer JAR, other process waits using
  // exponential backoff.
  final jarExists = await File(jarFile).exists();
  log.info(jarExists);
  log.info(jarFile);
  final isJarStale = jarExists &&
      await isPackageModifiedAfter(
          'jnigen', await File(jarFile).lastModified(), 'java/');
  if (isJarStale) {
    log.info('Rebuilding ApiSummarizer component since sources '
        'have changed. This might take some time.');
  }
  if (!jarExists) {
    log.info('Building ApiSummarizer component. '
        'This might take some time. '
        'The build will be cached for subsequent runs.');
  }
  if (!jarExists || isJarStale || force) {
    await buildApiSummarizer();
  } else {
    log.info('ApiSummarizer.jar exists. Skipping build..');
  }
}
