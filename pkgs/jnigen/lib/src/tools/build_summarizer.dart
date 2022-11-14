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

import 'package:jnigen/src/util/find_package.dart';
import 'package:jnigen/src/logging/logging.dart';

final toolPath = join('.', '.dart_tool', 'jnigen');
final mvnTargetDir = join(toolPath, 'target');
final jarFile = join(toolPath, 'ApiSummarizer.jar');
final targetJarFile = join(mvnTargetDir, 'ApiSummarizer.jar');

Future<void> buildApiSummarizer() async {
  final pkg = await findPackageRoot('jnigen');
  if (pkg == null) {
    log.fatal('package jnigen not found!');
    return;
  }
  final pom = pkg.resolve('java/pom.xml');
  await Directory(toolPath).create(recursive: true);
  final mvnArgs = [
    '--batch-mode',
    '--update-snapshots',
    '-f',
    pom.toFilePath(),
    'assembly:assembly'
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
      printError("maven exited with $exitCode");
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
  final isJarStale = jarExists &&
      await isPackageModifiedAfter(
          'jnigen', await File(jarFile).lastModified(), 'java/');
  if (isJarStale) {
    log.info('Rebuilding ApiSummarizer component since sources '
        'have changed. This might take some time.');
  }
  if (!jarExists) {
    log.info('Building ApiSummarizer component. '
        'This might take some time. \n'
        'The build will be cached for subsequent runs\n');
  }
  if (!jarExists || isJarStale || force) {
    await buildApiSummarizer();
  } else {
    log.info('ApiSummarizer.jar exists. Skipping build..');
  }
}
