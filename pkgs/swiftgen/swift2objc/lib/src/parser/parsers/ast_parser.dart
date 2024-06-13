import '../_core/utils.dart';
import 'declaration_parser.dart';

class AstParser {
  final ParsedSymbolsMap parsedSymbolsMap;

  AstParser(this.parsedSymbolsMap);

  DeclarationsMap parse() {
    final DeclarationsMap declarations = {};

    for (final id in parsedSymbolsMap.keys) {
      declarations[id] = DeclarationParser(id, parsedSymbolsMap).parse();
    }

    return declarations;
  }
}
