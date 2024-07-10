// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../tools.dart';
import '../config/config.dart';
import '../elements/elements.dart';
import '../generate_bindings.dart';
import '../logging/logging.dart';

class SummaryParseException implements Exception {
  final String? stderr;
  final String message;
  SummaryParseException(this.message) : stderr = null;
  SummaryParseException.withStderr(this.stderr, this.message);

  @override
  String toString() => message;
}

/// A command based summary source which calls the ApiSummarizer command.
/// [sourcePaths] and [classPaths] can be provided for the summarizer to find
/// required dependencies. The [classes] argument specifies the fully qualified
/// names of classes or packages included in the generated summary. when a
/// package is specified, its contents are included recursively.
///
/// When the default summarizer scans the [sourcePaths], it assumes that
/// the directory names reflect actual package paths. For example, a class name
/// com.example.pkg.Cls will be mapped to com/example/pkg/Cls.java.
///
/// The default summarizer needs to be built with `jnigen:setup`
/// script before this API is used.
class SummarizerCommand {
  SummarizerCommand({
    this.command = "java -jar .dart_tool/jnigen/ApiSummarizer.jar",
    List<Uri>? sourcePath,
    List<Uri>? classPath,
    this.extraArgs = const [],
    required this.classes,
    this.workingDirectory,
    this.backend,
  })  : sourcePaths = sourcePath ?? [],
        classPaths = classPath ?? [];

  static const sourcePathsOption = '-s';
  static const classPathsOption = '-c';

  String command;
  List<Uri> sourcePaths, classPaths;

  List<String> extraArgs;
  List<String> classes;

  Uri? workingDirectory;
  SummarizerBackend? backend;

  void addSourcePaths(List<Uri> paths) {
    sourcePaths.addAll(paths);
  }

  void addClassPaths(List<Uri> paths) {
    classPaths.addAll(paths);
  }

  void _addPathParam(List<String> args, String option, List<Uri> paths) {
    if (paths.isNotEmpty) {
      final joined = paths
          .map((uri) => uri.toFilePath())
          .join(Platform.isWindows ? ';' : ':');
      args.addAll([option, '"$joined"']);
    }
  }

  Future<Process> runProcess() async {
    final commandSplit = command.split(" ");
    final exec = commandSplit[0];
    final List<String> args = commandSplit.sublist(1);

    _addPathParam(args, sourcePathsOption, sourcePaths);
    _addPathParam(args, classPathsOption, classPaths);
    if (backend != null) {
      args.addAll(['--backend', backend!.name]);
    }
    args.addAll(extraArgs);
    args.addAll(classes);
    log.info('execute $exec ${args.join(' ')}');
    final proc = await Process.start(
      exec,
      args,
      workingDirectory: workingDirectory?.toFilePath() ?? '.',
      environment: {'JAVA_TOOL_OPTIONS': '-Dfile.encoding=UTF8'},
    );
    return proc;
  }
}

Future<Classes> getSummary(Config config) async {
  // This function is a potential entry point in tests, which set log level to
  // warning.
  setLoggingLevel(config.logLevel);
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
  if (androidConfig != null && androidConfig.addGradleSources) {
    final deps = AndroidSdkTools.getGradleSources(
      configRoot: config.configRoot,
      androidProject: androidConfig.androidExample ?? '.',
    );
    extraSources.addAll(deps.map(Uri.file));
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
  final stopwatch = Stopwatch()..start();
  try {
    process = await summarizer.runProcess();
    input = process.stdout;
  } on Exception catch (e) {
    throw SummaryParseException('Cannot generate API summary: $e');
  }
  final stderrBuffer = StringBuffer();
  collectOutputStream(process.stderr, stderrBuffer);
  final stream = const JsonDecoder().bind(const Utf8Decoder().bind(input));
  dynamic json;
  try {
    json = await stream.single;
    stopwatch.stop();
    log.info('Parsing inputs took ${stopwatch.elapsedMilliseconds} ms');
  } on Exception catch (e) {
    await process.exitCode;
    throw SummaryParseException.withStderr(
      stderrBuffer.toString(),
      'Cannot generate summary: $e',
    );
  } finally {
    log.writeSectionToFile("summarizer logs", stderrBuffer.toString());
  }
  if (json == null) {
    throw SummaryParseException('Expected JSON element from summarizer.');
  }
  final classes = Classes.fromJson(json as List<dynamic>);
  return classes;
}
