// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../ast/_core/interfaces/declaration.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/utils.dart';
import 'declaration_parsers/parse_compound_declaration.dart';
import 'declaration_parsers/parse_function_declaration.dart';
import 'declaration_parsers/parse_initializer_declaration.dart';
import 'declaration_parsers/parse_variable_declaration.dart';

List<Declaration> parseDeclarations(ParsedSymbolgraph symbolgraph) {
  final declarations = <Declaration>[];

  for (final symbol in symbolgraph.symbols.values) {
    final declaration = tryParseDeclaration(symbol, symbolgraph);
    if (declaration != null) {
      declarations.add(declaration);
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

  if (isObsoleted(symbolJson)) {
    throw ObsoleteException(parseSymbolId(symbolJson));
  }

  final symbolType = symbolJson['kind']['identifier'].get<String>();

  parsedSymbol.declaration = switch (symbolType) {
    'swift.class' => parseClassDeclaration(parsedSymbol, symbolgraph),
    'swift.struct' => parseStructDeclaration(parsedSymbol, symbolgraph),
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

Declaration? tryParseDeclaration(
  ParsedSymbol parsedSymbol,
  ParsedSymbolgraph symbolgraph,
  {bool debug = false}
) {
  try {
    return parseDeclaration(parsedSymbol, symbolgraph);
  } catch (e) {
    if (debug) print(e);
    Logger.root.severe('$e');
  }
  return null;
}
