import '../_core/type_defs.dart';
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
