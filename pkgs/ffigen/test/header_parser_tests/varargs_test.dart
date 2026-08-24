// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../test_utils.dart';

late Library actual;

void main() {
  group('varargs_test', () {
    setUpAll(() {
      actual = parser.parse(
        testContext(
          YamlConfig.fromYaml(
            yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'VarArgs Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - '${absPath('test/header_parser_tests/varargs.h')}'

${strings.functions}:
  ${strings.varArgFunctions}:
    myfunc:
      - [int, char*, SA]
    myfunc2:
      - [char*, long**]
      - [SA, int*, unsigned char**]
      - types: [SA, int*, unsigned char**]
        postfix: _custompostfix
    myfunc3:
      - [Struct_WithLong_Name_test*, float*]
      - types: [Struct_WithLong_Name_test]
        postfix: _custompostfix2
        ''')
                as yaml.YamlMap,
            createTestLogger(),
          ).configAdapter(),
        ),
      );
    });
    test('Expected Bindings', () {
      final context = testContext();
      matchLibraryWithExpected(
        context,
        actual,
        'header_parser_varargs_test_output.dart',
        [
          'test',
          'header_parser_tests',
          'expected_bindings',
          '_expected_varargs_bindings.dart',
        ],
      );
    });

    test('Programmatic Visitor manipulation of Func.varArgs', () {
      final config = YamlConfig.fromYaml(
        yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'VarArgs Visitor Test'
${strings.output}: 'unused'

${strings.headers}:
  ${strings.entryPoints}:
    - '${absPath('test/header_parser_tests/varargs.h')}'
''')
            as yaml.YamlMap,
        createTestLogger(),
      ).configAdapter();

      var visitedVariadicFunc = false;
      config.visitors.add(
        public_ast.Visitor(
          func: (node) {
            if (node.isVariadic && node.name == 'myfunc') {
              visitedVariadicFunc = true;
              expect(node.isVariadic, isTrue);
              node.varArgs = [
                VarArgFunction(postfix: 'Suffix', types: ['int', 'double']),
              ];
            }
          },
        ),
      );

      final context = testContext(config);
      final lib = parser.parse(context);
      expect(visitedVariadicFunc, isTrue);

      final myfuncSuffix = lib.bindings.whereType<Func>().firstWhere(
        (f) => f.name == 'myfuncSuffix',
      );
      expect(myfuncSuffix.functionType.varArgParameters, hasLength(2));
      expect(myfuncSuffix.functionType.varArgParameters[0].type, intType);
      expect(myfuncSuffix.functionType.varArgParameters[1].type, doubleType);

      matchLibraryWithExpected(
        context,
        lib,
        'header_parser_varargs_visitor_test_output.dart',
        [
          'test',
          'header_parser_tests',
          'expected_bindings',
          '_expected_varargs_visitor_bindings.dart',
        ],
      );
    });
  });
}
