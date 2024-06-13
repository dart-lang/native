import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../_core/parsed_symbol.dart';
import '../_core/utils.dart';

final _builtInDeclarations = [
  BuiltInDeclaration(id: "s:SS", name: "String"),
  BuiltInDeclaration(id: "s:Si", name: "Int"),
  BuiltInDeclaration(id: "s:Sd", name: "Double"),
];

class SymbolgraphJsonParser {
  final JsonMap symbolgraphJson;

  SymbolgraphJsonParser(this.symbolgraphJson);

  ParsedSymbolsMap parse() {
    final parsedSymbols = {
      for (final decl in _builtInDeclarations)
        decl.id: ParsedSymbol(json: {}, declaration: decl)
    };

    for (final symbolJson in symbolgraphJson["symbols"]) {
      final symbolId = parseSymbolId(symbolJson);
      parsedSymbols[symbolId] = ParsedSymbol(json: symbolJson);
    }

    return parsedSymbols;
  }
}
