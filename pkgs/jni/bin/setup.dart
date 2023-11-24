// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:package_config/package_config.dart';

import 'package:jni/src/build_util/build_util.dart';

const jniNativeBuildDirective =
    '# jni_native_build (Build with jni:setup. Do not delete this line.)';

// When changing this constant here, also change corresponding path in
// test/test_util.
const _defaultRelativeBuildPath = "build/jni_libs";

const _buildPath = "build-path";
const _srcPath = "add-source";
const _packageName = 'add-package';
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
  int status;
  if (options.verbose) {
    final process = await Process.start(
      exec, args,
      workingDirectory: workingDir,
      mode: ProcessStartMode.inheritStdio,
      // without `runInShell`, sometimes cmake doesn't run on windows.
      runInShell: true,
    );
    status = await process.exitCode;
    if (status != 0) {
      exitCode = status;
    }
  } else {
    // ProcessStartMode.normal sometimes hangs on windows. No idea why.
    final process = await Process.run(exec, args,
        runInShell: true, workingDirectory: workingDir);
    status = process.exitCode;
    if (status != 0) {
      exitCode = status;
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
  if (status != 0) {
    stderr.writeln('Command exited with status code $status');
  }
}

class Options {
  Options(ArgResults arg)
      : buildPath = arg[_buildPath],
        sources = arg[_srcPath],
        packages = arg[_packageName],
        cmakeArgs = arg[_cmakeArgs],
        verbose = arg[_verbose] ?? false;

  String? buildPath;
  List<String> sources;
  List<String> packages;
  List<String> cmakeArgs;
  bool verbose;
}

late Options options;

void verboseLog(String msg) {
  if (options.verbose) {
    stderr.writeln(msg);
  }
}

/// Find path to C or Java sources in pub cache for package specified by
/// [packageName].
///
/// If package cannot be found, null is returned.
Future<String> findSources(String packageName, String subDirectory) async {
  final packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig == null) {
    throw UnsupportedError("Please run from project root.");
  }
  final package = packageConfig[packageName];
  if (package == null) {
    throw UnsupportedError("Cannot find package: $packageName");
  }
  return package.root.resolve(subDirectory).toFilePath();
}

/// Return '/src' directories of all dependencies which has a CMakeLists.txt
/// file.
Future<Map<String, String>> findDependencySources() async {
  final packageConfig = await findPackageConfig(Directory.current);
  if (packageConfig == null) {
    throw UnsupportedError("Please run the command from project root.");
  }
  final sources = <String, String>{};
  for (var package in packageConfig.packages) {
    final src = package.root.resolve("src/");
    final cmakeLists = src.resolve("CMakeLists.txt");
    final cmakeListsFile = File.fromUri(cmakeLists);
    if (cmakeListsFile.existsSync()) {
      final firstLine = cmakeListsFile.readAsLinesSync().first;
      if (firstLine == jniNativeBuildDirective) {
        sources[package.name] = src.toFilePath();
      }
    }
  }
  return sources;
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
    ..addMultiOption(_srcPath,
        abbr: 's', help: 'alternative path to package:jni sources')
    ..addMultiOption(_packageName,
        abbr: 'p',
        help: 'package for which native'
            'library should be built')
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

  final sources = options.sources;
  for (var packageName in options.packages) {
    // It's assumed C FFI sources are in "src/" relative to package root.
    sources.add(await findSources(packageName, 'src'));
  }
  if (sources.isEmpty) {
    final dependencySources = await findDependencySources();
    stderr.writeln("selecting source directories for dependencies: "
        "${dependencySources.keys}");
    sources.addAll(dependencySources.values);
  } else {
    stderr.writeln("selecting source directories: $sources");
  }
  if (sources.isEmpty) {
    stderr.writeln('No source paths to build!');
    exitCode = 1;
    return;
  }

  final currentDirUri = Uri.directory(".");
  final buildPath = options.buildPath ??
      currentDirUri.resolve(_defaultRelativeBuildPath).toFilePath();
  final buildDir = Directory(buildPath);
  await buildDir.create(recursive: true);

  final javaSrc = await findSources('jni', 'java');
  final targetJar = File.fromUri(buildDir.uri.resolve('jni.jar'));
  if (!needsBuild(targetJar, Directory.fromUri(Uri.directory(javaSrc)))) {
    verboseLog('Last modified of ${targetJar.path}: '
        '${targetJar.lastModifiedSync()}.');
    stderr.writeln('Target newer than source, skipping build.');
  } else {
    verboseLog('Running mvn package for jni java sources to $buildPath.');
    await runCommand(
      'mvn',
      ['package', '-Dtarget=${buildDir.absolute.path}'],
      await findSources('jni', 'java'),
    );
  }

  for (var srcPath in sources) {
    final srcDir = Directory(srcPath);
    if (!srcDir.existsSync()) {
      stderr.writeln('Directory $srcPath does not exist');
      exitCode = 1;
      return;
    }

    verboseLog("srcPath: $srcPath");
    verboseLog("buildPath: $buildPath");

    final targetFileUri = buildDir.uri.resolve(getTargetName(srcDir));
    final targetFile = File.fromUri(targetFileUri);
    if (!needsBuild(targetFile, srcDir)) {
      verboseLog("Last modified of ${targetFile.path}: "
          "${targetFile.lastModifiedSync()}.");
      stderr.writeln('Target newer than source, skipping build.');
      continue;
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
      verboseLog(entry.toString());
      final dllSuffix = Platform.isWindows
          ? "dll"
          : Platform.isMacOS
              ? "dylib"
              : "so";
      if (entry.path.endsWith(dllSuffix)) {
        final dllName = entry.uri.pathSegments.last;
        final target = buildDir.uri.resolve(dllName);
        entry.renameSync(target.toFilePath());
      }
    }
    await tempDir.delete(recursive: true);
  }
}
