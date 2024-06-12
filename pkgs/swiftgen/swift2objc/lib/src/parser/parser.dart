import '_core/type_defs.dart';
import 'parsers/ast_parser.dart';
import 'parsers/relations_parser.dart';
import 'parsers/symbolgraph_json_parser.dart';
import 'parsers/symbolgraph_json_reader.dart';

class Parser {
  final String symbolgraphJsonPath;

  Parser(this.symbolgraphJsonPath);

  DeclarationsMap parse() {
    final symbolgraph = SymbolgraphJsonReader(symbolgraphJsonPath).read();

    final parsedSymbols = SymbolgraphJsonParser(symbolgraph).parse();

    final declarations = AstParser(parsedSymbols).parse();

    RelationsParser(symbolgraph, declarations).wireUp();

    return declarations;
  }
}
