// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/config_provider/spec_utils.dart';
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
        config.compilerOpts,
        equals([if (Platform.isMacOS) '-Wno-nullability-completeness']),
      );
    });
  });
}
