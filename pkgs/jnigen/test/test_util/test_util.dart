// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/logging/logging.dart';
import 'package:jnigen/src/util/find_package.dart';
import 'package:logging/logging.dart' show Level;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

final _currentDirectory = Directory('.');

// If changing these constants, grep for these values. In some places, test
// package expects string literals.
const largeTestTag = 'large_test';
const summarizerTestTag = 'summarizer_test';

Directory getTempDir(String prefix) {
  return _currentDirectory.createTempSync(prefix);
}

Future<bool> isEmptyOrNotExistDir(String path) async {
  final dir = Directory(path);
  return (!await dir.exists()) || (await dir.list().length == 0);
}

/// Runs command, and prints output only if the exit status is non-zero.
Future<int> runCommandReturningStatus(String exec, List<String> args,
    {String? workingDirectory, bool runInShell = false}) async {
  final proc = await Process.run(exec, args,
      workingDirectory: workingDirectory, runInShell: runInShell);
  if (proc.exitCode != 0) {
    printError('command exited with exit status ${proc.exitCode}:\n'
        '$exec ${args.join(" ")}\n');
    printError(proc.stdout);
    printError(proc.stderr);
  }
  return proc.exitCode;
}

Future<void> runCommand(
  String exec,
  List<String> args, {
  String? workingDirectory,
  bool runInShell = false,
  String? messageOnFailure,
}) async {
  final status = await runCommandReturningStatus(
    exec,
    args,
    workingDirectory: workingDirectory,
    runInShell: runInShell,
  );
  if (status != 0) {
    final message = messageOnFailure ?? 'Failed to execute $exec';
    throw Exception('$message: Command exited with return code $status');
  }
}

/// List all JAR files in [testRoot]/jar
Future<List<String>> getJarPaths(String testRoot) async {
  final jarPath = join(testRoot, 'jar');
  if (!await Directory(jarPath).exists()) {
    return [];
  }
  return Directory(jarPath)
      .list()
      .map((entry) => entry.path)
      .where((path) => path.endsWith('.jar'))
      .toList();
}

/// Read file normalizing CRLF to LF.
String readFile(File file) => file.readAsStringSync().replaceAll('\r\n', '\n');

/// Compares 2 hierarchies using `git diff --no-index`.
void comparePaths(String path1, String path2) {
  final diffCommand = [
    'diff',
    '--no-index',
    if (stderr.supportsAnsiEscapes) '--color=always',
  ];
  final diffProc = Process.runSync('git', [...diffCommand, path1, path2]);
  if (diffProc.exitCode != 0) {
    final originalDiff = diffProc.stdout;
    log.warning(
        'Paths $path1 and $path2 differ, Running dart format on $path1.');
    Process.runSync('dart', ['format', path1]);
    final fallbackDiffProc =
        Process.runSync('git', [...diffCommand, path1, path2]);
    if (fallbackDiffProc.exitCode != 0) {
      stderr.writeln(originalDiff);
      throw Exception('Paths $path1 and $path2 differ');
    }
  }
}

Future<void> _generateTempBindings(Config config, Directory tempDir) async {
  final singleFile =
      config.outputConfig.dartConfig.structure == OutputStructure.singleFile;
  final tempLib = singleFile
      ? tempDir.uri.resolve('generated.dart')
      : tempDir.uri.resolve('lib/');
  config.outputConfig.dartConfig.path = tempLib;
  config.logLevel = Level.WARNING;
  await generateJniBindings(config);
}

/// Generates and compares bindings with reference bindings.
///
/// `dartReferenceBindings` can be directory or file depending on output
/// configuration.
Future<void> generateAndCompareBindings(Config config) async {
  final dartReferenceBindings =
      config.outputConfig.dartConfig.path.toFilePath();
  final currentDir = Directory.current;
  final tempDir = currentDir.createTempSync('jnigen_test_temp');
  final singleFile =
      config.outputConfig.dartConfig.structure == OutputStructure.singleFile;
  final tempLib = singleFile
      ? tempDir.uri.resolve('generated.dart')
      : tempDir.uri.resolve('lib/');
  try {
    await _generateTempBindings(config, tempDir);
    comparePaths(dartReferenceBindings, tempLib.toFilePath());
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

Future<void> generateAndAnalyzeBindings(Config config,
    {Iterable<String> confirmExists = const []}) async {
  final tempDir = Directory.current.createTempSync('jnigen_test_temp');
  try {
    await _generateTempBindings(config, tempDir);
    final analyzeResult = Process.runSync('dart', ['analyze', tempDir.path]);
    if (analyzeResult.exitCode != 0) {
      stderr.write(analyzeResult.stdout);
      fail('Analyzer exited with non-zero status (${analyzeResult.exitCode})');
    }
    final singleFile =
        config.outputConfig.dartConfig.structure == OutputStructure.singleFile;
    if (!singleFile && confirmExists.isNotEmpty) {
      throw UnimplementedError('Currently only supports single file mode '
          'for confirming that classes exists');
    } else if (singleFile && confirmExists.isNotEmpty) {
      final generatedCode =
          await File.fromUri(tempDir.uri.resolve('generated.dart'))
              .readAsString();
      for (final className in confirmExists) {
        if (!generatedCode.contains(className)) {
          fail('$className does not exist in the generated bindings');
        }
      }
    }
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

final summarizerJar = join('.', '.dart_tool', 'jnigen', 'ApiSummarizer.jar');

Future<void> failIfSummarizerNotBuilt() async {
  final jarExists = await File(summarizerJar).exists();
  if (!jarExists) {
    stderr.writeln();
    log.fatal('Please build summarizer by running '
        '`dart run jnigen:setup` and try again');
  }
  final isJarStale = jarExists &&
      await isPackageModifiedAfter(
          'jnigen', await File(summarizerJar).lastModified(), 'java/');
  if (isJarStale) {
    stderr.writeln();
    log.fatal('Summarizer is not rebuilt after recent changes. '
        'Please run `dart run jnigen:setup` and try again.');
  }
}

const bindingTests = [
  'jackson_core_test',
  'simple_package_test',
  'kotlin_test',
];

const registrantName = 'runtime_test_registrant.dart';

/// Verifies if locally built dependencies (currently `ApiSummarizer`)
/// are up-to-date.
Future<void> checkLocallyBuiltDependencies() async {
  await failIfSummarizerNotBuilt();
}

void generateAndCompare(
  String description,
  Config config,
) {
  test(description, () async {
    await generateAndCompareBindings(config);
  }, timeout: const Timeout(Duration(minutes: 2)));
}

List<String> findFilesWithSuffix(Directory dir, String suffix) {
  return dir
      .listSync(recursive: true)
      .map((entry) => relative(entry.path, from: dir.path))
      .where((path) => path.endsWith(suffix))
      .toList();
}

Future<void> compileJavaFiles(Directory root, Directory target) async {
  final javaFiles = findFilesWithSuffix(root, '.java');
  await runCommand(
    'javac',
    ['-d', target.absolute.path, ...javaFiles],
    workingDirectory: root.path,
    messageOnFailure: 'Cannot compile java sources',
  );
}
