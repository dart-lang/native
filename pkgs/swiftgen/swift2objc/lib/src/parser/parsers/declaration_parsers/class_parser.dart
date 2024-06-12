import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils/parse_symbol_id.dart';
import '../../_core/utils/parse_symbol_name.dart';
import '../declaration_parser.dart';

class ClassParser extends DeclarationParser {
  ClassParser(super.parsedSymbolId, super.parsedSymbolsMap);

  @override
  ClassDeclaration parse() {
    return ClassDeclaration(
      id: parseSymbolId(parsedSymbol.json),
      name: parseSymbolName(parsedSymbol.json),
    );
  }
}
