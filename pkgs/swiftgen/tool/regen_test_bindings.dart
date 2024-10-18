// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;

import '../test/integration/util.dart';

Future<void> regenIntegrationTestBindings(String name) async {
  final gen = TestGenerator(name);
  await gen.generateBindings();
  await File(gen.outputFile).copy(gen.actualOutputFile);
}

const testSuffix = '_test.dart';
List<String> findAllIntegrationTests() =>
   Directory(TestGenerator('').testDir)
      .listSync()
      .map((entity) => path.basename(entity.path))
      .where((f) => f.endsWith(testSuffix))
      .map((f) => f.substring(0, f.length - testSuffix.length)).toList();

Future<void> main(List<String> args) async {
  for (final name in args.isEmpty ? findAllIntegrationTests() : args) {
    await regenIntegrationTestBindings(name);
  }
}
