// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer';

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_class_decalartion.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_method_declaration.dart';

List<Declaration> parseDeclarations(ParsedSymbolgraph symbolgraph) {
  final List<Declaration> declarations = [];

  for (final symbol in symbolgraph.symbols.values) {
    try {
      final declaration = parseDeclaration(symbol, symbolgraph);
      declarations.add(declaration);
    } on UnimplementedError catch (e) {
      log("$e");
    }
  }

  return declarations;
}

Declaration parseDeclaration(
  ParsedSymbol parsedSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  if (parsedSymbol.declaration != null) {
    return parsedSymbol.declaration!;
  }

  final symbolJson = parsedSymbol.json;

  final String symbolType = symbolJson["kind"]["identifier"].get();

  parsedSymbol.declaration = switch (symbolType) {
    "swift.class" => parseClassDeclaration(symbolJson, symbolgraph),
    "swift.method" => parseMethodDeclaration(symbolJson, symbolgraph),
    _ => throw UnimplementedError(
        "Symbol of type ${symbolType} is not implemented yet.",
      ),
  } as Declaration;

  return parsedSymbol.declaration!;
}
