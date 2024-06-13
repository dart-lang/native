import 'dart:developer';

import '../_core/utils.dart';
import 'declaration_parser.dart';

class AstParser {
  final ParsedSymbolsMap parsedSymbolsMap;

  AstParser(this.parsedSymbolsMap);

  DeclarationsMap parse() {
    final DeclarationsMap declarations = {};

    for (final id in parsedSymbolsMap.keys) {
      try {
        declarations[id] = DeclarationParser(id, parsedSymbolsMap).parse();
      } on UnsupportedError catch (e) {
        if (e.message != null) {
          log(e.message!);
        }
      }
    }

    return declarations;
  }
}
