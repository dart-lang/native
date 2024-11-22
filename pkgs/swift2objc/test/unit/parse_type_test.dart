// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/_core/token_list.dart';
import 'package:swift2objc/src/parser/parsers/parse_type.dart';
import 'package:test/test.dart';

void main() {
  final parsedSymbols = ParsedSymbolgraph({
    for (final decl in BuiltInDeclaration.values)
      decl.id: ParsedSymbol(json: Json(null), declaration: decl)
  }, {});

  test('Type identifier', () {
    final fragments = Json(jsonDecode(
      '''
      [
        {
          "kind": "typeIdentifier",
          "spelling": "Int",
          "preciseIdentifier": "s:Si"
        }
      ]
      ''',
    ));

    final (type, remaining) = parseType(parsedSymbols, TokenList(fragments));

    expect(type.sameAs(intType), isTrue);
    expect(remaining.length, 0);
  });

  test('Empty tuple', () {
    final fragments = Json(jsonDecode(
      '''
      [
        {
          "kind": "text",
          "spelling": "()"
        }
      ]
      ''',
    ));

    final (type, remaining) = parseType(parsedSymbols, TokenList(fragments));

    expect(type.sameAs(voidType), isTrue);
    expect(remaining.length, 0);
  });

  test('Optional', () {
    final fragments = Json(jsonDecode(
      '''
      [
        {
          "kind": "typeIdentifier",
          "spelling": "Int",
          "preciseIdentifier": "s:Si"
        },
        {
          "kind": "text",
          "spelling": "?"
        }
      ]
      ''',
    ));

    final (type, remaining) = parseType(parsedSymbols, TokenList(fragments));

    expect(type.sameAs(OptionalType(intType)), isTrue);
    expect(remaining.length, 0);
  });

  test('Multiple suffixes', () {
    // This test is verifying that we can parse multiple suffix operators in a
    // row. Nested OptionalTypes don't really make sense though. So in future if
    // we start collapsing nested OptionalTypes, change this test to use a
    // different suffix type.
    final fragments = Json(jsonDecode(
      '''
      [
        {
          "kind": "typeIdentifier",
          "spelling": "Int",
          "preciseIdentifier": "s:Si"
        },
        {
          "kind": "text",
          "spelling": "?"
        },
        {
          "kind": "text",
          "spelling": "?"
        },
        {
          "kind": "text",
          "spelling": "?"
        }
      ]
      ''',
    ));

    final (type, remaining) = parseType(parsedSymbols, TokenList(fragments));

    expect(type.sameAs(OptionalType(intType)), isFalse);
    expect(
        type.sameAs(OptionalType(OptionalType(OptionalType(intType)))), isTrue);
    expect(remaining.length, 0);
  });

  test('Stop parsing when we find a non-type token', () {
    final fragments = Json(jsonDecode(
      '''
      [
        {
          "kind": "typeIdentifier",
          "spelling": "Int",
          "preciseIdentifier": "s:Si"
        },
        {
          "kind": "text",
          "spelling": "?"
        },
        {
          "kind": "text",
          "spelling": ","
        },
        {
          "kind": "typeIdentifier",
          "spelling": "Int",
          "preciseIdentifier": "s:Si"
        }
      ]
      ''',
    ));

    final (type, remaining) = parseType(parsedSymbols, TokenList(fragments));

    expect(type.sameAs(OptionalType(intType)), isTrue);
    expect(remaining.length, 2);
  });
}
