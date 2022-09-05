// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';

import 'package:jnigen/src/util/find_package.dart';

final toolPath = join('.', '.dart_tool', 'jnigen');
final mvnTargetDir = join(toolPath, 'target');
final jarFile = join(toolPath, 'ApiSummarizer.jar');
final targetJarFile = join(mvnTargetDir, 'ApiSummarizer.jar');

Future<void> buildApiSummarizer() async {
  final pkg = await findPackageRoot('jnigen');
  if (pkg == null) {
    stderr.writeln('package jnigen not found!');
    exitCode = 2;
    return;
  }
  final pom = pkg.resolve('java/pom.xml');
  await Directory(toolPath).create(recursive: true);
  final mvnProc = await Process.start(
      'mvn',
      [
        '--batch-mode',
        '--update-snapshots',
        '-f',
        pom.toFilePath(),
        'assembly:assembly'
      ],
      workingDirectory: toolPath,
      mode: ProcessStartMode.inheritStdio);
  await mvnProc.exitCode;
  File(targetJarFile).renameSync(jarFile);
  Directory(mvnTargetDir).deleteSync(recursive: true);
}

Future<void> buildSummarizerIfNotExists({bool force = false}) async {
  final jarExists = await File(jarFile).exists();
  final isJarStale = jarExists &&
      await isPackageModifiedAfter(
          'jnigen', await File(jarFile).lastModified(), 'java/');
  if (isJarStale) {
    stderr.writeln('Rebuilding ApiSummarizer component since sources '
        'have changed. This might take some time.');
  }
  if (!jarExists) {
    stderr.write('Building ApiSummarizer component. '
        'This might take some time. \n'
        'The build will be cached for subsequent runs\n');
  }
  if (!jarExists || isJarStale || force) {
    await buildApiSummarizer();
  } else {
    stderr.writeln('ApiSummarizer.jar exists. Skipping build..');
  }
}
