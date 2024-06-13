import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';
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
