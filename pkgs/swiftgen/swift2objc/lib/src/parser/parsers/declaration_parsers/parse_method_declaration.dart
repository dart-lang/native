import 'package:swift2objc/src/parser/parsers/parse_declarations_map.dart';

import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassMethodDeclaration parseMethodDeclaration(
  JsonMap methodSymbolJson,
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
  JsonMap methodSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final returnTypeId =
      methodSymbolJson["functionSignature"]["returns"][0]["preciseIdentifier"];
  final returnTypeDeclaration = parseDeclaration(
    returnTypeId,
    parsedSymbolsMap,
  );
  return DeclaredType(id: returnTypeId, declaration: returnTypeDeclaration);
}

List<Parameter> _parseMethodParams(
  JsonMap methodSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final List paramList = methodSymbolJson["functionSignature"]["parameters"];

  return paramList
      .map(
        (param) => Parameter(
          name: param["name"],
          internalName: param["internalName"],
          type: _parseParamType(param, parsedSymbolsMap),
        ),
      )
      .toList();
}

ReferredType _parseParamType(
  JsonMap paramSymbolJson,
  ParsedSymbolsMap parsedSymbolsMap,
) {
  final List fragments = paramSymbolJson["declarationFragments"];

  final paramTypeId = fragments.firstWhere(
    (fragment) => fragment["kind"] == "typeIdentifier",
  )["preciseIdentifier"];

  final paramTypeDeclaration = parseDeclaration(
    paramTypeId,
    parsedSymbolsMap,
  );

  return DeclaredType(id: paramTypeId, declaration: paramTypeDeclaration);
}
