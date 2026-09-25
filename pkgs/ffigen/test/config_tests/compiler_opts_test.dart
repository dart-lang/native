// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/config_provider/spec_utils.dart';
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('compiler_opts_test', () {
    test('Compiler Opts', () {
      final opts =
          '''--option value "in double quotes" 'in single quotes'  -tab=separated''';
      final list = compilerOptsToList(opts);
      expect(list, <String>[
        '--option',
        'value',
        'in double quotes',
        'in single quotes',
        '-tab=separated',
      ]);
    });
    test('Compiler Opts Automatic', () {
      try {
        final config = testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Compiler Opts Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - '${absPath('test/header_parser_tests/comment_markup.h')}'
${strings.compilerOptsAuto}:
  ${strings.macos}:
    ${strings.includeCStdLib}: false
        ''');
        expect(
          config.input.compilerOptions,
          equals([if (Platform.isMacOS) '-Wno-nullability-completeness']),
        );
      } on ProcessException {
        // clang not available on local machine without LLVM installed.
      }
    });
    test('C++ defaults', () {
      final opts = defaultCompilerOpts(createTestLogger(), cpp: true);
      expect(opts, [
        '-x',
        'c++',
        '-std=c++17',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ]);
    });
    test('computeCompilerOpts', () {
      final logger = createTestLogger();
      final defaultOpts = defaultCompilerOpts(logger);
      FfiGenerator testGen({Input input = const Input(), Cpp? cpp}) =>
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused.dart'))),
            input: input,
            cpp: cpp,
          );

      // Overwrites defaults when appendCompilerOptions is false or omitted.
      final overwriteOpts = computeCompilerOpts(
        config: testGen(input: const Input(compilerOptions: ['-DFOO'])),
        logger: logger,
      );
      expect(overwriteOpts, ['-DFOO']);

      // Appends to defaults when appendCompilerOptions is true.
      final appendOpts = computeCompilerOpts(
        config: testGen(
          input: const Input(
            compilerOptions: ['-DFOO'],
            appendCompilerOptions: true,
          ),
        ),
        logger: logger,
      );
      expect(appendOpts, [...defaultOpts, '-DFOO']);

      // Uses defaults when compilerOptions is null even if
      // appendCompilerOptions is true.
      final nullAppendOpts = computeCompilerOpts(
        config: testGen(input: const Input(appendCompilerOptions: true)),
        logger: logger,
      );
      expect(nullAppendOpts, defaultOpts);

      // Appends to C++ defaults when C++ is enabled.
      final defaultCppOpts = defaultCompilerOpts(logger, cpp: true);
      final cppAppendOpts = computeCompilerOpts(
        config: testGen(
          input: const Input(
            compilerOptions: ['-DFOO'],
            appendCompilerOptions: true,
          ),
          cpp: const Cpp(),
        ),
        logger: logger,
      );
      expect(cppAppendOpts, [...defaultCppOpts, '-DFOO']);
    });
    test('Context.compilerOpts', () {
      try {
        final defaultOpts = defaultCompilerOpts(createTestLogger());
        final contextAppend = Context(
          createTestLogger(),
          FfiGenerator(
            output: Output(dart: DartOutput(path: Uri.file('unused.dart'))),
            input: const Input(
              compilerOptions: ['-DFOO'],
              appendCompilerOptions: true,
            ),
          ),
        );
        expect(contextAppend.compilerOpts, [...defaultOpts, '-DFOO']);
      } on ProcessException {
        // clang not available on local machine without LLVM installed.
      }
    });
  });
}
