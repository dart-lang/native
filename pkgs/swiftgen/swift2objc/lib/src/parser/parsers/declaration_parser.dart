import '../../ast/_core/interfaces/declaration.dart';
import '../_core/parsed_symbol.dart';
import '../_core/utils.dart';
import 'declaration_parsers/class_parser.dart';
import 'declaration_parsers/method_parser.dart';

class DeclarationParser {
  final ParsedSymbolsMap parsedSymbolsMap;
  final String parsedSymbolId;

  DeclarationParser(this.parsedSymbolId, this.parsedSymbolsMap);

  ParsedSymbol get parsedSymbol => parsedSymbolsMap[parsedSymbolId]!;

  Declaration parse() {
    if (parsedSymbol.declaration != null) {
      return parsedSymbol.declaration!;
    }

    final symbolJson = parsedSymbol.json;

    final String symbolType = symbolJson["kind"]["identifier"];

    final parser = switch (symbolType) {
      "swift.class" => ClassParser(parsedSymbolId, parsedSymbolsMap),
      "swift.method" => MethodParser(parsedSymbolId, parsedSymbolsMap),
      _ => throw UnsupportedError(
          "Symbol of type ${symbolType} is not supported",
        ),
    };

    parsedSymbol.declaration = parser.parse();
    return parsedSymbol.declaration!;
  }
}
