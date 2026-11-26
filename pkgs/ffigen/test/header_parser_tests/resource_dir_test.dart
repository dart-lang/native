// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for https://github.com/dart-lang/native/issues/3629.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/public_visitor.dart';
import 'package:ffigen/src/header_parser/parser.dart' as parser;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  final headerUri = Uri.file(
    path.join(
      packagePathForTests,
      'test',
      'header_parser_tests',
      'resource_dir.h',
    ),
  );

  Library parseHeader({
    List<String>? compilerOptions,
    bool appendCompilerOptions = false,
    Cpp? cpp,
  }) {
    return parser.parse(
      testContext(
        FfiGenerator(
          output: Output(
            dart: DartOutput(path: Uri.file('unused')),
            style: const DynamicLibraryBindings(),
          ),
          cpp: cpp,
          input: Input(
            entryPoints: [headerUri],
            include: (header) => header.path.endsWith('resource_dir.h'),
            compilerOptions: compilerOptions,
            appendCompilerOptions: appendCompilerOptions,
          ),
          visitors: [Visitor(func: (node) => node.isIncluded = true)],
        ),
      ),
    );
  }

  group('resource_dir_test', () {
    test('default C mode (compilerOptions: null)', () {
      final lib = parseHeader();
      expect(lib.getBinding('probe'), isA<Func>());
    });

    test('default C++ mode (compilerOptions: null)', () {
      final lib = parseHeader(cpp: const Cpp());
      expect(lib.getBinding('probe'), isA<Func>());
    });

    test('custom compilerOptions with appendCompilerOptions: true', () {
      final lib = parseHeader(
        compilerOptions: const ['-DFOO=1'],
        appendCompilerOptions: true,
      );
      expect(lib.getBinding('probe'), isA<Func>());
    });

    test(
      'custom -resource-dir with appendCompilerOptions: true overrides default',
      () {
        final resourceDirResult = Process.runSync('clang', [
          '-print-resource-dir',
        ]);
        expect(resourceDirResult.exitCode, 0);
        final resourceDir = (resourceDirResult.stdout as String).trim();

        final lib = parseHeader(
          compilerOptions: ['-resource-dir=$resourceDir'],
          appendCompilerOptions: true,
        );
        expect(lib.getBinding('probe'), isA<Func>());
      },
    );
  });
}
