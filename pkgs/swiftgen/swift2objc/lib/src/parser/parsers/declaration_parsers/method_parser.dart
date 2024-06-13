import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';
import '../declaration_parser.dart';

class MethodParser extends DeclarationParser {
  MethodParser(super.parsedSymbolId, super.parsedSymbolsMap);

  ClassMethodDeclaration parse() {
    return ClassMethodDeclaration(
      id: parseSymbolId(parsedSymbol.json),
      name: parseSymbolName(parsedSymbol.json),
      returnType: _parseMehodReturnType(parsedSymbol.json),
      params: _parseMehodParams(parsedSymbol.json),
    );
  }

  ReferredType _parseMehodReturnType(JsonMap methodSymbolJson) {
    final returnTypeId = methodSymbolJson["functionSignature"]["returns"][0]
        ["preciseIdentifier"];
    final returnTypeDeclaration = DeclarationParser(
      returnTypeId,
      parsedSymbolsMap,
    ).parse();
    return DeclaredType(id: returnTypeId, declaration: returnTypeDeclaration);
  }

  List<Parameter> _parseMehodParams(JsonMap methodSymbolJson) {
    final List paramList = methodSymbolJson["functionSignature"]["parameters"];

    return paramList
        .map(
          (param) => Parameter(
            name: param["name"],
            internalName: param["internalName"],
            type: _parseParamType(param),
          ),
        )
        .toList();
  }

  ReferredType _parseParamType(JsonMap paramSymbolJson) {
    final List fragments = paramSymbolJson["declarationFragments"];

    final paramTypeId = fragments.firstWhere(
      (fragment) => fragment["kind"] == "typeIdentifier",
    )["preciseIdentifier"];

    final paramTypeDeclaration = DeclarationParser(
      paramTypeId,
      parsedSymbolsMap,
    ).parse();

    return DeclaredType(id: paramTypeId, declaration: paramTypeDeclaration);
  }
}
