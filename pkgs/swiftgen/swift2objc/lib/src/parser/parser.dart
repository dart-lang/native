import '_core/utils.dart';
import 'parsers/parse_declarations_map.dart';
import 'parsers/wire_up_relations.dart';
import 'parsers/parse_symbols_map.dart';

DeclarationsMap parseAst(String symbolgraphJsonPath) {
  final symbolgraph = readJsonFile(symbolgraphJsonPath);

  final parsedSymbols = parseSymbolsMap(symbolgraph);

  final declarations = parseDeclarationsMap(parsedSymbols);

  wireUpRelations(declarations, symbolgraph);

  return declarations;
}
