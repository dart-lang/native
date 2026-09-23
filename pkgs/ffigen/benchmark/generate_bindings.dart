// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

Future<void> generateBenchmarkBindings() async {
  final stopwatch = Stopwatch()..start();
  final pkgRoot = Directory.current.uri;
  final testDir = pkgRoot.resolve('test/native_objc_test/');
  final benchmarkDir = pkgRoot.resolve('benchmark/');
  await Directory.fromUri(benchmarkDir).create(recursive: true);

  print('Generating bindings with autorelease pool...');
  final configWith = FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: benchmarkDir.resolve('method_with_pool_bindings.dart'),
      ),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('method_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          node.isIncluded = node.originalName == 'MethodInterface';
        },
      ),
    ],
  );
  await configWith.generate();

  print('Generated in ${stopwatch.elapsedMilliseconds}ms');
}

Future<void> main() async {
  await generateBenchmarkBindings();
}
