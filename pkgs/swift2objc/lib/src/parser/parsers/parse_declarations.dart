// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer';

import '../../ast/_core/interfaces/declaration.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/utils.dart';
import 'declaration_parsers/parse_compound_declaration.dart';
import 'declaration_parsers/parse_initializer_declaration.dart';
import 'declaration_parsers/parse_variable_declaration.dart';
import 'declaration_parsers/pase_function_declaration.dart';

List<Declaration> parseDeclarations(ParsedSymbolgraph symbolgraph) {
  final declarations = <Declaration>[];

  for (final symbol in symbolgraph.symbols.values) {
    try {
      final declaration = parseDeclaration(symbol, symbolgraph);
      declarations.add(declaration);
    } catch (e) {
      log('$e');
    }
  }

  return declarations.topLevelOnly;
}

Declaration parseDeclaration(
  ParsedSymbol parsedSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  if (parsedSymbol.declaration != null) {
    return parsedSymbol.declaration!;
  }

  final symbolJson = parsedSymbol.json;

  final symbolType = symbolJson['kind']['identifier'].get<String>();

  parsedSymbol.declaration = switch (symbolType) {
    'swift.class' => parseClassDeclaration(symbolJson, symbolgraph),
    'swift.struct' => parseStructDeclaration(symbolJson, symbolgraph),
    'swift.method' =>
      parseMethodDeclaration(symbolJson, symbolgraph, isStatic: false),
    'swift.type.method' =>
      parseMethodDeclaration(symbolJson, symbolgraph, isStatic: true),
    'swift.property' =>
      parsePropertyDeclaration(symbolJson, symbolgraph, isStatic: false),
    'swift.type.property' =>
      parsePropertyDeclaration(symbolJson, symbolgraph, isStatic: true),
    'swift.init' => parseInitializerDeclaration(symbolJson, symbolgraph),
    'swift.func' => parseGlobalFunctionDeclaration(symbolJson, symbolgraph),
    'swift.var' => parseGlobalVariableDeclaration(symbolJson, symbolgraph),
    _ => throw Exception(
        'Symbol of type $symbolType is not implemented yet.',
      ),
  } as Declaration;

  return parsedSymbol.declaration!;
}
