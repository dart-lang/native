// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/util/command_output.dart';

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
        classPaths = classPath ?? [] {
    if (backend != null && !{'asm', 'doclet'}.contains(backend)) {
      throw ArgumentError('Supported backends: asm, doclet');
    }
  }

  static const sourcePathsOption = '-s';
  static const classPathsOption = '-c';

  String command;
  List<Uri> sourcePaths, classPaths;

  List<String> extraArgs;
  List<String> classes;

  Uri? workingDirectory;
  String? backend;

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
      if (option.endsWith("=")) {
        args.add(option + joined);
      } else {
        args.addAll([option, joined]);
      }
    }
  }

  Future<Stream<List<int>>> getInputStream() async {
    final commandSplit = command.split(" ");
    final exec = commandSplit[0];
    final List<String> args = commandSplit.sublist(1);

    _addPathParam(args, sourcePathsOption, sourcePaths);
    _addPathParam(args, classPathsOption, classPaths);
    if (backend != null) {
      args.addAll(['--backend', backend!]);
    }
    args.addAll(extraArgs);
    args.addAll(classes);

    log.info('execute $exec ${args.join(' ')}');
    final proc = await Process.start(exec, args,
        workingDirectory: workingDirectory?.toFilePath() ?? '.');
    prefixedCommandOutputStream('[ApiSummarizer]', proc.stderr)
        .forEach(stderr.writeln);
    return proc.stdout;
  }
}
