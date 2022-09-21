// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  log.info('execute mvn $mvnArgs');
  final mvnProc = await Process.start('mvn', mvnArgs,
      workingDirectory: toolPath,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio);
  await mvnProc.exitCode;
  await File(targetJarFile).rename(jarFile);
  await Directory(mvnTargetDir).delete(recursive: true);
}

Future<void> buildSummarizerIfNotExists({bool force = false}) async {
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
