// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:package_config/package_config.dart';

const _buildDir = "build-dir";
const _srcDir = "source-dir";
const _packageName = 'package-name';
const _verbose = "verbose";
const _cmakeArgs = "cmake-args";
const _clean = "clean";

const _cmakeTemporaryFiles = [
  'CMakeCache.txt',
  'CMakeFiles/',
  'cmake_install.cmake',
  'Makefile'
];

void deleteCMakeTemps(Uri buildDir) async {
  for (var filename in _cmakeTemporaryFiles) {
    if (options.verbose) {
      stderr.writeln('remove $filename');
    }
    await File(buildDir.resolve(filename).toFilePath()).delete(recursive: true);
  }
}

// Sets up input output channels and maintains state.
class CommandRunner {
  CommandRunner({this.printCmds = false});
  bool printCmds = false;
  int? time;
  Future<CommandRunner> run(
      String exec, List<String> args, String workingDir) async {
    if (printCmds) {
      final cmd = "$exec ${args.join(" ")}";
      stderr.writeln("\n+ [$workingDir] $cmd");
    }
    final process = await Process.start(exec, args,
        workingDirectory: workingDir,
        runInShell: true,
        mode: ProcessStartMode.inheritStdio);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      stderr.writeln("command exited with $exitCode");
    }
    return this;
  }
}

class Options {
  Options(ArgResults arg)
      : buildDir = arg[_buildDir],
        srcDir = arg[_srcDir],
        packageName = arg[_packageName] ?? 'jni',
        cmakeArgs = arg[_cmakeArgs],
        verbose = arg[_verbose] ?? false,
        clean = arg[_clean] ?? false;

  String? buildDir, srcDir;
  String packageName;
  List<String> cmakeArgs;
  bool verbose, clean;
}

late Options options;
void log(String msg) {
  if (options.verbose) {
    stderr.writeln(msg);
  }
}

/// tries to find package:jni's source folder in pub cache
/// if not possible, returns null.
Future<String?> findSources() async {
  final packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig == null) {
    return null;
  }
  final packages = packageConfig.packages;
  for (var package in packages) {
    if (package.name == options.packageName) {
      return package.root.resolve("src/").toFilePath();
    }
  }
  return null;
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(_buildDir,
        abbr: 'B', help: 'Directory to place built artifacts')
    ..addOption(_srcDir,
        abbr: 'S', help: 'alternative path to package:jni sources')
    ..addOption(_packageName,
        abbr: 'p',
        help: 'package for which native'
            'library should be built',
        defaultsTo: 'jni')
    ..addFlag(_verbose, abbr: 'v', help: 'Enable verbose output')
    ..addFlag(_clean,
        negatable: false,
        abbr: 'C',
        help: 'Clear built artifacts instead of running a build')
    ..addMultiOption(_cmakeArgs,
        abbr: 'm', help: 'additional argument to pass to CMake');
  final cli = parser.parse(arguments);
  options = Options(cli);
  final rest = cli.rest;

  if (rest.isNotEmpty) {
    stderr.writeln("one or more unrecognized arguments: $rest");
    stderr.writeln("usage: dart run jni:setup <options>");
    stderr.writeln(parser.usage);
    exitCode = 1;
    return;
  }

  final srcPath = options.srcDir ?? await findSources();

  if (srcPath == null) {
    stderr.writeln("No sources specified and current directory is not a "
        "package root.");
    exitCode = 1;
    return;
  }

  final srcDir = Directory(srcPath);
  if (!await srcDir.exists() && !options.clean) {
    throw 'Directory $srcPath does not exist';
  }

  log("srcPath: $srcPath");

  final currentDirUri = Uri.file(".");
  final buildPath =
      options.buildDir ?? currentDirUri.resolve("build/jni_libs").toFilePath();
  final buildDir = Directory(buildPath);
  await buildDir.create(recursive: true);
  log("buildPath: $buildPath");

  if (buildDir.absolute.uri == srcDir.absolute.uri) {
    stderr.writeln("Please build in a directory different than source.");
    exit(2);
  }

  if (options.clean) {
    await cleanup(options, srcDir.absolute.path, buildDir.absolute.path);
  } else {
    // pass srcDir absolute path because it will be passed to CMake as arg
    // which will be running in different directory
    await build(options, srcDir.absolute.path, buildDir.path);
  }
}

Future<void> build(Options options, String srcPath, String buildPath) async {
  final runner = CommandRunner(printCmds: true);
  final cmakeArgs = <String>[];
  cmakeArgs.addAll(options.cmakeArgs);
  cmakeArgs.add(srcPath);
  await runner.run("cmake", cmakeArgs, buildPath);
  await runner.run("cmake", ["--build", "."], buildPath);
  final buildPathUri = Uri.directory(buildPath);
  if (Platform.isWindows) {
    final debugDir = buildPathUri.resolve('Debug');
    for (var entry in Directory.fromUri(debugDir).listSync()) {
      if (entry.path.endsWith('.dll')) {
        final fileName = entry.uri.pathSegments.last;
        final target = entry.parent.parent.uri.resolve(fileName);
        log('rename ${entry.path} -> ${target.toFilePath()}');
        entry.rename(target.toFilePath());
      }
    }
  }
  // delete cmakeTemporaryArtifacts
  deleteCMakeTemps(Uri.directory(buildPath));
}

Future<void> cleanup(Options options, String srcPath, String buildPath) async {
  if (srcPath == buildPath) {
    stderr.writeln('Error: build path is same as source path.');
  }

  stderr.writeln("deleting $buildPath");

  try {
    await Directory(buildPath).delete(recursive: true);
  } catch (e) {
    stderr.writeln("Error: cannot be deleted");
    stderr.writeln(e);
  }
}
