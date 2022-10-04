// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:package_config/package_config.dart';

const ansiRed = '\x1b[31m';
const ansiDefault = '\x1b[39;49m';

const _defaultRelativeBuildPath = "build/jni_libs";

const _buildPath = "build-path";
const _srcPath = "source-path";
const _packageName = 'package-name';
const _verbose = "verbose";
const _cmakeArgs = "cmake-args";

Future<void> runCommand(
    String exec, List<String> args, String workingDir) async {
  // For printing relative path always.
  var current = Directory.current.path;
  if (!current.endsWith(Platform.pathSeparator)) {
    current += Platform.pathSeparator;
  }
  if (workingDir.startsWith(current)) {
    workingDir.replaceFirst(current, "");
  }

  final cmd = "$exec ${args.join(" ")}";
  stderr.writeln("+ [$workingDir] $cmd");
  int exitCode;
  if (options.verbose) {
    final process = await Process.start(
      exec, args,
      workingDirectory: workingDir,
      mode: ProcessStartMode.inheritStdio,
      // without `runInShell`, sometimes cmake doesn't run on windows.
      runInShell: true,
    );
    exitCode = await process.exitCode;
  } else {
    // ProcessStartMode.normal sometimes hangs on windows. No idea why.
    final process = await Process.run(exec, args,
        runInShell: true, workingDirectory: workingDir);
    exitCode = process.exitCode;
    if (exitCode != 0) {
      var out = process.stdout;
      var err = process.stderr;
      if (stdout.supportsAnsiEscapes) {
        out = "$ansiRed$out$ansiDefault";
        err = "$ansiRed$err$ansiDefault";
      }
      stdout.writeln(out);
      stderr.writeln(err);
    }
  }
  if (exitCode != 0) {
    stderr.writeln("Command exited with $exitCode.");
  }
}

class Options {
  Options(ArgResults arg)
      : buildPath = arg[_buildPath],
        srcPath = arg[_srcPath],
        packageName = arg[_packageName] ?? 'jni',
        cmakeArgs = arg[_cmakeArgs],
        verbose = arg[_verbose] ?? false;

  String? buildPath, srcPath;
  String packageName;
  List<String> cmakeArgs;
  bool verbose;
}

late Options options;

void verboseLog(String msg) {
  if (options.verbose) {
    stderr.writeln(msg);
  }
}

/// Find path to C sources in pub cache for package specified by [packageName].
///
/// It's assumed C FFI sources are in "src/" relative to package root.
/// If package cannot be found, null is returned.
Future<String?> findSources(String packageName) async {
  final packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig == null) {
    return null;
  }
  final package = packageConfig[options.packageName];
  if (package == null) {
    return null;
  }
  return package.root.resolve("src").toFilePath();
}

/// Returns true if [artifact] does not exist, or any file in [sourceDir] is
/// newer than [artifact].
bool needsBuild(File artifact, Directory sourceDir) {
  if (!artifact.existsSync()) return true;
  final fileLastModified = artifact.lastModifiedSync();
  for (final entry in sourceDir.listSync(recursive: true)) {
    if (entry.statSync().modified.isAfter(fileLastModified)) {
      return true;
    }
  }
  return false;
}

/// Returns the name of file built using sources in [cDir]
String getTargetName(Directory cDir) {
  for (final file in cDir.listSync(recursive: true)) {
    if (file.path.endsWith(".c")) {
      final cFileName = file.uri.pathSegments.last;
      final librarySuffix = Platform.isWindows ? "dll" : "so";
      return cFileName.substring(0, cFileName.length - 1) + librarySuffix;
    }
  }
  throw Exception("Could not find a C file in ${cDir.path}");
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(_buildPath,
        abbr: 'b', help: 'Directory to place built artifacts')
    ..addOption(_srcPath,
        abbr: 's', help: 'alternative path to package:jni sources')
    ..addOption(_packageName,
        abbr: 'p',
        help: 'package for which native'
            'library should be built',
        defaultsTo: 'jni')
    ..addFlag(_verbose, abbr: 'v', help: 'Enable verbose output')
    ..addMultiOption(_cmakeArgs,
        abbr: 'm', help: 'Pass additional argument to CMake');
  final argResults = parser.parse(arguments);
  options = Options(argResults);
  final rest = argResults.rest;

  if (rest.isNotEmpty) {
    stderr.writeln("one or more unrecognized arguments: $rest");
    stderr.writeln("usage: dart run jni:setup <options>");
    stderr.writeln(parser.usage);
    exitCode = 1;
    return;
  }

  final srcPath = options.srcPath ?? await findSources(options.packageName);

  if (srcPath == null) {
    stderr.writeln("Cannot find sources for package ${options.packageName} "
        "and no sources were manually specified.");
    exitCode = 1;
    return;
  }

  final srcDir = Directory(srcPath);
  if (!srcDir.existsSync()) {
    stderr.writeln('Directory $srcPath does not exist');
    exitCode = 1;
    return;
  }

  verboseLog("srcPath: $srcPath");

  final currentDirUri = Uri.directory(".");
  final buildPath = options.buildPath ??
      currentDirUri.resolve(_defaultRelativeBuildPath).toFilePath();
  final buildDir = Directory(buildPath);
  await buildDir.create(recursive: true);
  verboseLog("buildPath: $buildPath");

  if (buildDir.absolute.uri == srcDir.absolute.uri) {
    stderr.writeln("Please build in a directory different than source.");
    exitCode = 1;
    return;
  }

  final targetFileUri = buildDir.uri.resolve(getTargetName(srcDir));
  final targetFile = File.fromUri(targetFileUri);
  if (!needsBuild(targetFile, srcDir)) {
    verboseLog("last modified of ${targetFile.path}: "
        "${targetFile.lastModifiedSync()}");
    stderr.writeln("target newer than source, skipping build");
    return;
  }

  // Note: creating temp dir in .dart_tool/jni instead of SystemTemp
  // because latter can fail tests on Windows CI, when system temp is on
  // separate drive or something.
  final jniDirUri = Uri.directory(".dart_tool").resolve("jni");
  final jniDir = Directory.fromUri(jniDirUri);
  await jniDir.create(recursive: true);
  final tempDir = await jniDir.createTemp("jni_native_build_");
  final cmakeArgs = <String>[];
  cmakeArgs.addAll(options.cmakeArgs);
  // Pass absolute path of srcDir because cmake command is run in temp dir
  cmakeArgs.add(srcDir.absolute.path);
  await runCommand("cmake", cmakeArgs, tempDir.path);
  await runCommand("cmake", ["--build", "."], tempDir.path);
  final dllDirUri =
      Platform.isWindows ? tempDir.uri.resolve("Debug") : tempDir.uri;
  final dllDir = Directory.fromUri(dllDirUri);
  for (var entry in dllDir.listSync()) {
    final dllSuffix = Platform.isWindows ? "dll" : "so";
    if (entry.path.endsWith(dllSuffix)) {
      final dllName = entry.uri.pathSegments.last;
      final target = buildDir.uri.resolve(dllName);
      entry.renameSync(target.toFilePath());
    }
  }
  await tempDir.delete(recursive: true);
}
