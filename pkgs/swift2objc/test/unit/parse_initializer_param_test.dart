import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/_core/utils.dart';
import 'package:swift2objc/src/parser/parsers/declaration_parsers/parse_initializer_declaration.dart';
import 'package:test/test.dart';

void main() {
  group('`parseInitializerParam` test', () {
    final thisDir = path.join(Directory.current.path, 'test/unit');
    final inputJsonPath = path.join(
      thisDir,
      'parse_initializer_param_input.json',
    );
    final inputJsonArray = readJsonFile(inputJsonPath);
    final parsedSymbols = {
      for (final decl in BuiltInDeclaration.values)
        decl.id: ParsedSymbol(json: Json(null), declaration: decl)
    };
    final emptySymbolgraph = ParsedSymbolgraph(parsedSymbols, {});

    for (final json in inputJsonArray) {
      final testName = json['testName'].get<String>();
      final inputJson = json['inputJson'];
      final expectedOutputParams = json['outputParams'];

      test(testName, () {
        final outputParams = parseInitializerParams(
          inputJson,
          emptySymbolgraph,
        );

        for (var i = 0; i < outputParams.length; i++) {
          final outputParam = outputParams[i];
          final expectedParam = expectedOutputParams[i];
          expect(outputParam.name, expectedParam['name'].get<String>());
          expect(
            outputParam.internalName,
            expectedParam['internalName'].get<String?>(),
          );
          expect(outputParam.type.id, expectedParam['typeId'].get<String>());
        }
      });
    }
  });
}
