// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/tools/gradle_tools.dart';
import 'package:jnigen/tools.dart';
import 'package:path/path.dart';

/// Downloads maven dependencies downloaded by equivalent jnigen invocation.
///
/// Useful for running standalone examples on already generated sources.
void main(List<String> args) async {
  final config = Config.parseArgs(args);
  final mavenDownloads = config.mavenDownloads;
  if (mavenDownloads != null) {
    await GradleTools.downloadMavenSources(
        GradleTools.deps(mavenDownloads.sourceDeps), mavenDownloads.sourceDir);
    // Include sources in jar download to make sure transitive
    // dependencies are included
    await GradleTools.downloadMavenJars(
        GradleTools.deps(
            mavenDownloads.jarOnlyDeps + mavenDownloads.sourceDeps),
        mavenDownloads.jarDir);
    // // remove duplicated jars
    for (var dep in mavenDownloads.sourceDeps) {
      final filename =
          MavenDependency.fromString(dep).filename(isSource: false);
      File(join(mavenDownloads.jarDir, filename)).deleteSync();
    }
    await Directory(mavenDownloads.jarDir)
        .list()
        .map((entry) => entry.path)
        .where((path) => path.endsWith('.jar'))
        .forEach(stdout.writeln);
  } else {
    stderr.writeln('No maven dependencies found in config.');
    exitCode = 2;
  }
}
