// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_function_declaration.dart';
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

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'outerLabel',
          internalName: 'internalLabel',
          type: intType,
        ),
        Parameter(
          name: 'singleLabel',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
    });

    test('Three params with some optional', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "init" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "label1" },
          { "kind": "text", "spelling": " " },
          { "kind": "internalParam", "spelling": "param1" },
          { "kind": "text", "spelling": ": " },
          {
              "kind": "typeIdentifier",
              "spelling": "Int",
              "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": "?, " },
          { "kind": "externalParam", "spelling": "label2" },
          { "kind": "text", "spelling": ": " },
          {
              "kind": "typeIdentifier",
              "spelling": "Int",
              "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ", " },
          { "kind": "externalParam", "spelling": "label3" },
          { "kind": "text", "spelling": " " },
          { "kind": "internalParam", "spelling": "param3" },
          { "kind": "text", "spelling": ": " },
          {
              "kind": "typeIdentifier",
              "spelling": "Int",
              "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": "?)" }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'label1',
          internalName: 'param1',
          type: OptionalType(intType),
        ),
        Parameter(
          name: 'label2',
          type: intType,
        ),
        Parameter(
          name: 'label3',
          internalName: 'param3',
          type: OptionalType(intType),
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
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

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
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

      final info = parseFunctionInfo(json, emptySymbolgraph);

      expectEqualParams(info.params, []);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
    });

    test('Function with return type', () {
      // parseFunctionInfo doesn't parse the return type, but it should be able
      // to cope with one.
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "parameter" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ") -> " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
    });

    test('Function with no params with return type', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "() -> " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      expectEqualParams(info.params, []);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
    });

    test('Function with no params and no return type', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "()" }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      expectEqualParams(info.params, []);
      expect(info.throws, isFalse);
      expect(info.async, isFalse);
    });

    test('Function with return type that throws', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "parameter" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ") " },
          { "kind": "keyword", "spelling": "throws" },
          { "kind": "text", "spelling": " -> " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isTrue);
      expect(info.async, isFalse);
    });

    test('Function with no return type that throws', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "parameter" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ") " },
          { "kind": "keyword", "spelling": "throws" }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isTrue);
      expect(info.async, isFalse);
    });

    test('Function with no params that throws', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "() " },
          { "kind": "keyword", "spelling": "throws" }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      expectEqualParams(info.params, []);
      expect(info.throws, isTrue);
      expect(info.async, isFalse);
    });

    test('Function with async annotation', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "parameter" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ") " },
          { "kind": "keyword", "spelling": "async" },
          { "kind": "text", "spelling": " -> " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isFalse);
      expect(info.async, isTrue);
    });

    test('Function with async and throws annotations', () {
      final json = Json(jsonDecode(
        '''
        [
          { "kind": "keyword", "spelling": "func" },
          { "kind": "text", "spelling": " " },
          { "kind": "identifier", "spelling": "foo" },
          { "kind": "text", "spelling": "(" },
          { "kind": "externalParam", "spelling": "parameter" },
          { "kind": "text", "spelling": ": " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          },
          { "kind": "text", "spelling": ") " },
          { "kind": "keyword", "spelling": "async" },
          { "kind": "text", "spelling": " " },
          { "kind": "keyword", "spelling": "throws" },
          { "kind": "text", "spelling": " -> " },
          {
            "kind": "typeIdentifier",
            "spelling": "Int",
            "preciseIdentifier": "s:Si"
          }
        ]
        ''',
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      final expectedParams = [
        Parameter(
          name: 'parameter',
          type: intType,
        ),
      ];

      expectEqualParams(info.params, expectedParams);
      expect(info.throws, isTrue);
      expect(info.async, isTrue);
    });


    test('Mutating Function that throws', () {
      final json = Json(jsonDecode(
        '''
        [
                {
                    "kind": "keyword",
                    "spelling": "mutating"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "keyword",
                    "spelling": "func"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "identifier",
                    "spelling": "moveBy"
                },
                {
                    "kind": "text",
                    "spelling": "("
                },
                {
                    "kind": "externalParam",
                    "spelling": "x"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "internalParam",
                    "spelling": "deltaX"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Double",
                    "preciseIdentifier": "s:Sd"
                },
                {
                    "kind": "text",
                    "spelling": ", "
                },
                {
                    "kind": "externalParam",
                    "spelling": "y"
                },
                {
                    "kind": "text",
                    "spelling": " "
                },
                {
                    "kind": "internalParam",
                    "spelling": "deltaY"
                },
                {
                    "kind": "text",
                    "spelling": ": "
                },
                {
                    "kind": "typeIdentifier",
                    "spelling": "Double",
                    "preciseIdentifier": "s:Sd"
                },
                {
                    "kind": "text",
                    "spelling": ") "
                },
                {
                    "kind": "keyword",
                    "spelling": "throws"
                }
            ]
        '''
      ));

      final info = parseFunctionInfo(json, emptySymbolgraph);

      expect(info.throws, isTrue);
      expect(info.mutating, isTrue);
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
        () => parseFunctionInfo(json, emptySymbolgraph),
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
        () => parseFunctionInfo(json, emptySymbolgraph),
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
        () => parseFunctionInfo(json, emptySymbolgraph),
        throwsA(isA<Exception>()),
      );
    });
  });
}
