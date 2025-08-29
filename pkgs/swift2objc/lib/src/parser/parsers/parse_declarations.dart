// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../config.dart';
import '../../context.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/utils.dart';
import 'declaration_parsers/parse_built_in_declaration.dart';
import 'declaration_parsers/parse_compound_declaration.dart';
import 'declaration_parsers/parse_function_declaration.dart';
import 'declaration_parsers/parse_initializer_declaration.dart';
import 'declaration_parsers/parse_typealias_declaration.dart';
import 'declaration_parsers/parse_variable_declaration.dart';

List<Declaration> parseDeclarations(
  Context context,
  ParsedSymbolgraph symbolgraph,
) {
  final declarations = <Declaration>[];

  for (final symbol in symbolgraph.symbols.values) {
    final declaration = tryParseDeclaration(context, symbol, symbolgraph);
    if (declaration != null) {
      declarations.add(declaration);
    }
  }

  return declarations.topLevelOnly;
}

// TODO(https://github.com/dart-lang/native/issues/1815): Support for extensions
Declaration parseDeclaration(
  Context context,
  ParsedSymbol parsedSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  if (parsedSymbol.declaration != null) {
    return parsedSymbol.declaration!;
  }

  final symbolJson = parsedSymbol.json;

  final builtIn = tryParseBuiltInDeclaration(symbolJson);
  if (builtIn != null) {
    return parsedSymbol.declaration = builtIn;
  }

  if (isObsoleted(symbolJson)) {
    throw ObsoleteException(parseSymbolId(symbolJson));
  }

  final symbolType = symbolJson['kind']['identifier'].get<String>();

  parsedSymbol.declaration = switch (symbolType) {
    'swift.class' => parseClassDeclaration(context, parsedSymbol, symbolgraph),
    'swift.struct' => parseStructDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
    ),
    'swift.method' => parseMethodDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
      isStatic: false,
    ),
    'swift.type.method' => parseMethodDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
      isStatic: true,
    ),
    'swift.property' => parsePropertyDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
      isStatic: false,
    ),
    'swift.type.property' => parsePropertyDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
      isStatic: true,
    ),
    'swift.init' => parseInitializerDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
    ),
    'swift.func' => parseGlobalFunctionDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
    ),
    'swift.var' => parseGlobalVariableDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
    ),
    'swift.typealias' => parseTypealiasDeclaration(
      context,
      parsedSymbol,
      symbolgraph,
    ),
    _ => throw Exception('Symbol of type $symbolType is not implemented yet.'),
  };

  return parsedSymbol.declaration!;
}

Declaration? tryParseDeclaration(
  Context context,
  ParsedSymbol parsedSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  try {
    return parseDeclaration(context, parsedSymbol, symbolgraph);
  } catch (e) {
    if (parsedSymbol.source != builtInInputConfig) {
      context.logger.severe('$e');
    }
  }
  return null;
}
