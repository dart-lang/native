// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/declaration.dart';
import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/globals/globals.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

GlobalFunctionDeclaration parseGlobalFunctionDeclaration(
  Json globalFunctionSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return GlobalFunctionDeclaration(
    id: parseSymbolId(globalFunctionSymbolJson),
    name: parseSymbolName(globalFunctionSymbolJson),
    returnType: _parseFunctionReturnType(globalFunctionSymbolJson, symbolgraph),
    params: _parseFunctionParams(globalFunctionSymbolJson, symbolgraph),
  );
}

MethodDeclaration parseMethodDeclaration(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  return MethodDeclaration(
    id: parseSymbolId(methodSymbolJson),
    name: parseSymbolName(methodSymbolJson),
    returnType: _parseFunctionReturnType(methodSymbolJson, symbolgraph),
    params: _parseFunctionParams(methodSymbolJson, symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(methodSymbolJson),
    isStatic: isStatic,
  );
}

ReferredType? _parseFunctionReturnType(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final returnJson = methodSymbolJson['functionSignature']['returns'][0];

  // This means there's no return type
  if (returnJson['spelling'].get<String>() == '()') {
    return null;
  }

  final returnTypeId = returnJson['preciseIdentifier'].get<String>();

  final returnTypeSymbol = symbolgraph.symbols[returnTypeId];

  if (returnTypeSymbol == null) {
    throw Exception(
      'The method at path "${methodSymbolJson.path}" has a return type that '
      'does not exist among parsed symbols.',
    );
  }

  final returnTypeDeclaration = parseDeclaration(
    returnTypeSymbol,
    symbolgraph,
  );

  return returnTypeDeclaration.asDeclaredType;
}

List<Parameter> _parseFunctionParams(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final paramList = methodSymbolJson['functionSignature']['parameters'];

  if (!paramList.exists) return [];

  return paramList
      .map(
        (param) => Parameter(
          name: param['name'].get(),
          internalName: param['internalName'].get(),
          type: _parseParamType(param, symbolgraph),
        ),
      )
      .toList();
}

ReferredType _parseParamType(
  Json paramSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final fragments = paramSymbolJson['declarationFragments'];

  final paramTypeId = fragments
      .firstJsonWhereKey('kind', 'typeIdentifier')['preciseIdentifier']
      .get<String>();

  return parseTypeFromId(paramTypeId, symbolgraph);
}
