import 'dart:developer';

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbol.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_class_decalartion.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_method_declaration.dart';

import '../_core/utils.dart';

DeclarationsMap parseDeclarationsMap(ParsedSymbolsMap parsedSymbolsMap) {
  final DeclarationsMap declarations = {};

  for (final id in parsedSymbolsMap.keys) {
    try {
      declarations[id] = parseDeclaration(
        parsedSymbolsMap[id]!,
        parsedSymbolsMap,
      );
    } on UnimplementedError catch (e) {
      log("$e");
    }
  }

  return declarations;
}

Declaration parseDeclaration(
  ParsedSymbol parsedSymbol,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  if (parsedSymbol.declaration != null) {
    return parsedSymbol.declaration!;
  }

  final symbolJson = parsedSymbol.json;

  final String symbolType = symbolJson["kind"]["identifier"].get();

  parsedSymbol.declaration = switch (symbolType) {
    "swift.class" => parseClassDeclaration(symbolJson),
    "swift.method" => parseMethodDeclaration(symbolJson, parsedSymbolsMap),
    _ => throw UnimplementedError(
        "Symbol of type ${symbolType} is not implemented yet.",
      ),
  } as Declaration;

  return parsedSymbol.declaration!;
}
