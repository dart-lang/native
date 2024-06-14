import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';

import '_core/utils.dart';
import 'parsers/parse_declarations_map.dart';
import 'parsers/parse_realtions_map.dart';
import 'parsers/parse_symbols_map.dart';

DeclarationsMap parseAst(String symbolgraphJsonPath) {
  final symbolgraphJson = readJsonFile(symbolgraphJsonPath);

  final symbolgraph = ParsedSymbolgraph(
    parseSymbolsMap(symbolgraphJson),
    parseRelationsMap(symbolgraphJson),
  );

  final declarations = parseDeclarationsMap(symbolgraph);

  return declarations;
}
