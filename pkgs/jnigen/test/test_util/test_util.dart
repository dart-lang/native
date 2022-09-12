// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

Future<bool> hasNoFilesInDir(String path) async {
  final dir = Directory(path);
  return (!await dir.exists()) || (await dir.list().length == 0);
}

Future<int> runCmd(String exec, List<String> args,
    {String? workingDirectory}) async {
  stderr.writeln('[exec] $exec ${args.join(" ")}');
  final proc = await Process.start(exec, args,
      workingDirectory: workingDirectory,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio);
  return proc.exitCode;
}

Future<List<String>> getJarPaths(String testRoot) {
  final jarPath = join(testRoot, 'jar');
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
    expect(a.readAsStringSync(), equals(b.readAsStringSync()));
  }
}
