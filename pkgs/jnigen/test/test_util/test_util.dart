// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

Future<bool> isEmptyOrNotExistDir(String path) async {
  final dir = Directory(path);
  return (!await dir.exists()) || (await dir.list().length == 0);
}

/// Runs "$exec ${args...}" and returns exit code.
/// Required because only Process.start provides inheritStdio argument
Future<int> runCommand(String exec, List<String> args,
    {String? workingDirectory}) async {
  stderr.writeln('[exec] $exec ${args.join(" ")}');
  final proc = await Process.start(exec, args,
      workingDirectory: workingDirectory, mode: ProcessStartMode.inheritStdio);
  return await proc.exitCode;
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

/// compares 2 hierarchies, with and without prefix 'test_'
void compareDirs(String path1, String path2) {
  final list1 = Directory(path1).listSync(recursive: true);
  final list2 = Directory(path2).listSync(recursive: true);
  expect(list1.length, equals(list2.length));
  for (var list in [list1, list2]) {
    list.sort((a, b) => a.path.compareTo(b.path));
  }
  for (int i = 0; i < list1.length; i++) {
    if (list1[i].statSync().type != FileSystemEntityType.file) {
      continue;
    }
    final a = File(list1[i].path);
    final b = File(list2[i].path);
    // Some windows problems: Depending on your working tree and git config
    // one file may have CRLFs and other may have LFs.
    expect(a.readAsStringSync().replaceAll("\r\n", "\n"),
        equals(b.readAsStringSync().replaceAll("\r\n", "\n")));
  }
}

Future<void> _generateTempBindings(Config config, Directory tempDir) async {
  final tempSrc = tempDir.uri.resolve("src/");
  final tempLib = tempDir.uri.resolve("lib/");
  config.outputConfig.cConfig.path = tempSrc;
  config.outputConfig.dartConfig.path = tempLib;
  await generateJniBindings(config);
}

Future<void> generateAndCompareBindings(
    Config config, String lib, String src) async {
  final currentDir = Directory.current;
  final tempDir = currentDir.createTempSync("jnigen_test_temp");
  final tempSrc = tempDir.uri.resolve("src/");
  final tempLib = tempDir.uri.resolve("lib/");
  try {
    await _generateTempBindings(config, tempDir);
    compareDirs(lib, tempLib.toFilePath());
    compareDirs(src, tempSrc.toFilePath());
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

Future<void> generateAndAnalyzeBindings(Config config) async {
  final tempDir = Directory.current.createTempSync("jnigen_test_temp");
  try {
    await _generateTempBindings(config, tempDir);
    final analyzeResult = Process.runSync("dart", ["analyze", tempDir.path]);
    expect(analyzeResult.exitCode, equals(0),
        reason: "Analyzer exited with non-zero status");
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}
