// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart' show FfiGenerator, Input, Output;
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  final headerPath = absPath('test/rename_tests/dependency_rename.h');
  final headerUri = Uri.file(headerPath);

  group('Dependency-only declaration renaming', () {
    test('YamlConfig renames dependency-only struct', () {
      final config = testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Dependency Rename Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - '$headerPath'
  ${strings.includeDirectives}:
    - '**dependency_rename.h'
${strings.structs}:
  ${strings.rename}:
    'DepStruct': 'RenamedDepStruct'
''');

      final library = parser.parse(testContext(config));

      expect(library.getBinding('RenamedDepStruct'), isNotNull);
      expect(
        () => library.getBinding('DepStruct'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('Programmatic Visitor visits and renames dependency-only struct', () {
      var visitedDepStruct = false;

      final visitor = public_ast.Visitor(
        struct: (node) {
          if (node.name == 'DepStruct') {
            visitedDepStruct = true;
            node.name = 'RenamedDepStruct';
            node.isIncluded = true;
          }
        },
      );

      final config = FfiGenerator(
        output: Output(dartFile: Uri.file('unused.dart')),
        input: Input(
          entryPoints: [headerUri],
          include: (Uri header) => header == headerUri,
        ),
        visitors: [visitor],
      );

      final library = parser.parse(testContext(config));

      expect(visitedDepStruct, isTrue);
      expect(library.getBinding('RenamedDepStruct'), isNotNull);
      expect(
        () => library.getBinding('DepStruct'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('YamlConfig member-rename applies to dependency-only struct', () {
      final config = testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Dependency Member Rename Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - '$headerPath'
  ${strings.includeDirectives}:
    - '**dependency_rename.h'
${strings.structs}:
  ${strings.rename}:
    'DepStruct': 'RenamedDepStruct'
  ${strings.memberRename}:
    'DepStruct':
      'dep_field': 'renamed_field'
''');

      final library = parser.parse(testContext(config));
      final struct = library.getBinding('RenamedDepStruct') as Struct;
      expect(
        struct.members.any((m) => m.name == 'renamed_field'),
        isTrue,
      );
    });
  });
}
