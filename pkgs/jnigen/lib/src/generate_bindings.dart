// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'package:jnigen/src/util/command_output.dart';

import 'elements/elements.dart';
import 'summary/summary.dart';
import 'config/config.dart';
import 'tools/tools.dart';
import 'writers/writers.dart';
import 'logging/logging.dart';

Future<void> generateJniBindings(Config config) async {
  setLoggingLevel(config.logLevel);

  await buildSummarizerIfNotExists();

  final summarizer = SummarizerCommand(
    sourcePath: config.sourcePath,
    classPath: config.classPath,
    classes: config.classes,
    workingDirectory: config.summarizerOptions?.workingDirectory,
    extraArgs: config.summarizerOptions?.extraArgs ?? const [],
    backend: config.summarizerOptions?.backend,
  );

  // Additional sources added using maven downloads and gradle trickery.
  final extraSources = <Uri>[];
  final extraJars = <Uri>[];
  final mavenDl = config.mavenDownloads;
  if (mavenDl != null) {
    final sourcePath = mavenDl.sourceDir;
    await Directory(sourcePath).create(recursive: true);
    await MavenTools.downloadMavenSources(
        MavenTools.deps(mavenDl.sourceDeps), sourcePath);
    extraSources.add(Uri.directory(sourcePath));
    final jarPath = mavenDl.jarDir;
    await Directory(jarPath).create(recursive: true);
    await MavenTools.downloadMavenJars(
        MavenTools.deps(mavenDl.sourceDeps + mavenDl.jarOnlyDeps), jarPath);
    extraJars.addAll(await Directory(jarPath)
        .list()
        .where((entry) => entry.path.endsWith('.jar'))
        .map((entry) => entry.uri)
        .toList());
  }
  final androidConfig = config.androidSdkConfig;
  if (androidConfig != null && androidConfig.addGradleDeps) {
    final deps = AndroidSdkTools.getGradleClasspaths(
      configRoot: config.configRoot,
      androidProject: androidConfig.androidExample ?? '.',
    );
    extraJars.addAll(deps.map(Uri.file));
  }
  if (androidConfig != null && androidConfig.versions != null) {
    final versions = androidConfig.versions!;
    final androidSdkRoot =
        androidConfig.sdkRoot ?? AndroidSdkTools.getAndroidSdkRoot();
    final androidJar = await AndroidSdkTools.getAndroidJarPath(
        sdkRoot: androidSdkRoot, versionOrder: versions);
    if (androidJar != null) {
      extraJars.add(Uri.directory(androidJar));
    }
  }

  summarizer.addSourcePaths(extraSources);
  summarizer.addClassPaths(extraJars);

  Process process;
  Stream<List<int>> input;
  try {
    process = await summarizer.runProcess();
    input = process.stdout;
  } on Exception catch (e) {
    log.fatal('Cannot obtain API summary: $e');
    return;
  }
  final errorLog = StringBuffer();
  collectOutputStream(process.stderr, errorLog);
  final stream = JsonDecoder().bind(Utf8Decoder().bind(input));
  dynamic json;
  try {
    json = await stream.single;
  } on Exception catch (e) {
    printError(errorLog);
    log.fatal('Cannot parse summary: $e');
    return;
  }
  if (json == null) {
    log.fatal('Expected JSON element from summarizer.');
    return;
  }
  final list = json as List;
  final outputStructure = config.outputConfig.dartConfig.structure;
  BindingsWriter outputWriter;
  if (outputStructure == OutputStructure.packageStructure) {
    outputWriter = FilesWriter(config);
  } else {
    outputWriter = SingleFileWriter(config);
  }
  try {
    await outputWriter
        .writeBindings(list.map((c) => ClassDecl.fromJson(c)).toList());
  } on Exception catch (e, trace) {
    stderr.writeln(trace);
    log.fatal('Error while writing bindings: $e');
  }
}
