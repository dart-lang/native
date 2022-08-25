// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This script gets the java sources using the copy of this package, and builds
// ApiSummarizer jar using Maven.
import 'dart:io';

import 'package:path/path.dart';

import 'package:jni_gen/src/util/find_package.dart';

final toolPath = join('.', '.dart_tool', 'jni_gen');
final mvnTargetDir = join(toolPath, 'target');
final jarFile = join(toolPath, 'ApiSummarizer.jar');
final targetJarFile = join(mvnTargetDir, 'ApiSummarizer.jar');

Future<void> buildApiSummarizer() async {
  final pkg = await findPackageRoot('jni_gen');
  if (pkg == null) {
    stderr.writeln('package jni_gen not found!');
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
  // move ApiSummarizer.jar from target to current directory
  File(targetJarFile).renameSync(jarFile);
  Directory(mvnTargetDir).deleteSync(recursive: true);
}

void main(List<String> args) async {
  bool force = false;
  if (args.isNotEmpty) {
    if (args.length != 1 || args[0] != '-f') {
      stderr.writeln('usage: dart run jni_gen:setup [-f]');
      stderr.writeln('use -f option to rebuild ApiSummarizer jar '
          'even if it already exists.');
    } else {
      force = true;
    }
  }
  final jarExists = await File(jarFile).exists();
  final isJarStale = jarExists &&
      await isPackageModifiedAfter(
          'jni_gen', await File(jarFile).lastModified(), 'java/');
  if (isJarStale) {
    stderr.writeln('Rebuilding ApiSummarizer component since sources '
        'have changed. This might take some time.');
  }
  if (!jarExists || isJarStale || force) {
    await buildApiSummarizer();
  } else {
    stderr.writeln('ApiSummarizer.jar exists. Skipping build..');
  }
}
