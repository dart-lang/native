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
final gradleBuildDir = join('.','java', 'build');
final gradleTargetDir = join(gradleBuildDir, 'libs');
final jarFile = join(gradleTargetDir, 'ApiSummarizer.jar');
final targetJarFile = join(toolPath, 'ApiSummarizer.jar');

Future<Uri?> getGradleWExecutable() async{
  final pkg = await findPackageRoot('jnigen');
  if (Platform.isLinux || Platform.isMacOS) {
    return pkg!.resolve('gradlew');
  } else if (Platform.isWindows) {
    return pkg!.resolve('gradlew.bat');
  }
  return null;
}

Future<void> buildApiSummarizer() async {
  final pkg = await findPackageRoot('jnigen');
  if (pkg == null) {
    log.fatal('package jnigen not found!');
  }
  final gradleFile = pkg.resolve('java/build.gradle.kts');
  final gradleWrapper = await getGradleWExecutable();
  await Directory(toolPath).create(recursive: true);
  final gradleArgs = [
    '-b',
    gradleFile.toFilePath(),
    'buildFatJar',       // from ktor plugin
    '-x', 'test'   // ignore failing tests
  ];

  try {
    final gradleProc = await Process.run(gradleWrapper!.toFilePath(), gradleArgs,
        workingDirectory: toolPath, runInShell: true);
    final exitCode = gradleProc.exitCode;
    final sourceJar = File(pkg.resolve('java/build/libs/ApiSummarizer.jar').path);

    if (exitCode == 0) {
      sourceJar.copySync(targetJarFile);
    } else {
      printError(gradleProc.stdout);
      printError(gradleProc.stderr);
      printError('gradle exited with $exitCode');
    }
  } finally {
    // Remove build directory
    //if (Directory(gradleBuildDir).existsSync()) {
    //  await Directory(gradleBuildDir).delete(recursive: true);
    //}
  }
}

Future<void> buildSummarizerIfNotExists({bool force = false}) async {
  // TODO(#43): This function cannot be invoked concurrently because 2 processes
  // will start building summarizer at once. Introduce a locking mechnanism so
  // that when one process is building summarizer JAR, other process waits using
  // exponential backoff.
  final jarExists = await File(targetJarFile).exists();
  final isJarStale = jarExists &&
      await isPackageModifiedAfter(
          'jnigen', await File(targetJarFile).lastModified(), 'java/');
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
