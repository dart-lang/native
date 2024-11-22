// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_initializer_declaration.dart';
import 'package:test/test.dart';

void main() {
  final parsedSymbols = {
    for (final decl in BuiltInDeclaration.values)
      decl.id: ParsedSymbol(json: Json(null), declaration: decl)
  };
  final emptySymbolgraph = ParsedSymbolgraph(parsedSymbols, {});
  group('Valid json', () {
    void expectEqualParams(
      List<Parameter> actualParams,
      List<Parameter> expectedParams,
    ) {
      expect(actualParams.length, expectedParams.length);

      for (var i = 0; i < actualParams.length; i++) {
        final actualParam = actualParams[i];
        final expectedParam = expectedParams[i];

        expect(actualParam.name, expectedParam.name);
        expect(actualParam.internalName, expectedParam.internalName);
        expect(actualParam.type.sameAs(expectedParam.type), isTrue);
      }
    }

    test('Two params with one internal name', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "outerLabel" },
          { "kind": "text", "spelling": " " },
          { "kind": "internalParam", "spelling": "internalLabel" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ", " },
          { "kind": "externalParam", "spelling": "singleLabel" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ")" }
        ]
        ''',
      ));

      final outputParams = parseInitializerParams(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'outerLabel',
          internalName: 'internalLabel',
          type: BuiltInDeclaration.swiftInt.asDeclaredType,
        ),
        Parameter(
          name: 'singleLabel',
          type: BuiltInDeclaration.swiftInt.asDeclaredType,
        ),
      ];

      expectEqualParams(outputParams, expectedParams);
    });
    test('One param', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "parameter" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ")" }
        ]
        ''',
      ));

      final outputParams = parseInitializerParams(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: BuiltInDeclaration.swiftInt.asDeclaredType,
        ),
      ];

      expectEqualParams(outputParams, expectedParams);
    });

    test('No params', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "()" }
        ]
        ''',
      ));

      final outputParams = parseInitializerParams(json, emptySymbolgraph);

      expectEqualParams(outputParams, []);
    });
  });

  group('Invalid json', () {
    test('Parameter with no outer label', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "(" },
          { "kind": "internalParam", "spelling": "internalLabel" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ")" }
        ]
        ''',
      ));

      expect(
        () => parseInitializerParams(json, emptySymbolgraph),
        throwsA(isA<Exception>()),
      );
    });

    test('Parameter with no type', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "outerLabel" },
          { "kind": "text", "spelling": " " },
          { "kind": "internalParam", "spelling": "internalLabel" },
          { "kind": "text", "spelling": ")" }
        ]
        ''',
      ));

      expect(
        () => parseInitializerParams(json, emptySymbolgraph),
        throwsA(isA<Exception>()),
      );
    });

    test('Parameter with just a type (no label)', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "(" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ")" }
        ]
        ''',
      ));

      expect(
        () => parseInitializerParams(json, emptySymbolgraph),
        throwsA(isA<Exception>()),
      );
    });
  });
}
