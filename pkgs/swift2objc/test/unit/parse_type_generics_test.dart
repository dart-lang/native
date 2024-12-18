import 'package:path/path.dart' as p;
import 'package:swift2objc/src/ast/_core/interfaces/function_declaration.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/_core/utils.dart';
import 'package:swift2objc/src/parser/parsers/parse_declarations.dart';
import 'package:swift2objc/src/parser/parsers/parse_relations_map.dart';
import 'package:swift2objc/src/parser/parsers/parse_symbols_map.dart';
import 'package:test/test.dart';

void main() {

  group('General Test: Functions', () {
    final inputFile = p.join(p.current, 'test', 'unit', 
    'typegenerics_symbolgraph_module.symbols.json');
    final inputJson = readJsonFile(inputFile);
    final symbolgraph = ParsedSymbolgraph(
      parseSymbolsMap(inputJson),
      parseRelationsMap(inputJson),
    );
    final declarations = parseDeclarations(symbolgraph);
    final functionDeclarations = declarations.whereType<FunctionDeclaration>();

    test('Basic Type Generics', () {
      final firstTestDecl = functionDeclarations.firstWhere((d) => d.name == 'basicFunc');
      final secondTestDecl = functionDeclarations.firstWhere((d) => d.name == 'basicGenericFunc');

      assert(firstTestDecl.typeParams.isEmpty);
      assert(secondTestDecl.typeParams.isNotEmpty);
    });
  });
}