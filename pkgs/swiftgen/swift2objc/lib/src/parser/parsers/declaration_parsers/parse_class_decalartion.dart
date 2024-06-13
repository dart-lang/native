import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassDeclaration parseClassDeclaration(
  String parsedSymbolId,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final parsedSymbol = parsedSymbolsMap[parsedSymbolId]!;
  return ClassDeclaration(
    id: parseSymbolId(parsedSymbol.json),
    name: parseSymbolName(parsedSymbol.json),
  );
}
