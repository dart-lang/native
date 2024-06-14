import 'dart:developer';

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_class_decalartion.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_method_declaration.dart';

import '../_core/utils.dart';

DeclarationsMap parseDeclarationsMap(ParsedSymbolsMap parsedSymbolsMap) {
  final DeclarationsMap declarations = {};

  for (final id in parsedSymbolsMap.keys) {
    try {
      declarations[id] = parseDeclaration(id, parsedSymbolsMap);
    } on UnimplementedError catch (e) {
      log("$e");
    }
  }

  return declarations;
}

Declaration parseDeclaration(
    String parsedSymbolId, ParsedSymbolsMap parsedSymbolsMap) {
  final parsedSymbol = parsedSymbolsMap[parsedSymbolId]!;
  if (parsedSymbol.declaration != null) {
    return parsedSymbol.declaration!;
  }

  final symbolJson = parsedSymbol.json;

  final String symbolType = symbolJson["kind"]["identifier"];

  final ParserFunction parser = switch (symbolType) {
    "swift.class" => parseClassDeclaration,
    "swift.method" => parseMethodDeclaration,
    _ => throw UnimplementedError(
        "Symbol of type ${symbolType} is not implemented yet.",
      ),
  } as ParserFunction;

  parsedSymbol.declaration = parser(parsedSymbolId, parsedSymbolsMap);

  return parsedSymbol.declaration!;
}
