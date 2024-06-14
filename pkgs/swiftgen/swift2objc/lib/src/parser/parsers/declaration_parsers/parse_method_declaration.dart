import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/parsers/parse_declarations_map.dart';

import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassMethodDeclaration parseMethodDeclaration(
  Json methodSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  return ClassMethodDeclaration(
    id: parseSymbolId(methodSymbolJson),
    name: parseSymbolName(methodSymbolJson),
    returnType: _parseMethodReturnType(methodSymbolJson, parsedSymbolsMap),
    params: _parseMethodParams(methodSymbolJson, parsedSymbolsMap),
  );
}

ReferredType _parseMethodReturnType(
  Json methodSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final returnTypeId = methodSymbolJson["functionSignature"]["returns"][0]
          ["preciseIdentifier"]
      .get();
  final returnTypeDeclaration = parseDeclaration(
    returnTypeId,
    parsedSymbolsMap,
  );
  return DeclaredType(id: returnTypeId, declaration: returnTypeDeclaration);
}

List<Parameter> _parseMethodParams(
  Json methodSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final paramList = methodSymbolJson["functionSignature"]["parameters"];

  return paramList
      .map(
        (param) => Parameter(
          name: param["name"].get(),
          internalName: param["internalName"].get(),
          type: _parseParamType(param, parsedSymbolsMap),
        ),
      )
      .toList();
}

ReferredType _parseParamType(
  Json paramSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final fragments = paramSymbolJson["declarationFragments"];

  final paramTypeId = fragments
      .firstWhereKey("kind", "typeIdentifier")["preciseIdentifier"]
      .get();

  final paramTypeDeclaration = parseDeclaration(paramTypeId, parsedSymbolsMap);

  return DeclaredType(id: paramTypeId, declaration: paramTypeDeclaration);
}
