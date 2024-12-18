// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/compound_declaration.dart';
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
      returnType:
          _parseFunctionReturnType(globalFunctionSymbolJson, symbolgraph),
      params: _parseFunctionParams(globalFunctionSymbolJson, symbolgraph),
      typeParams:
          parseFunctionTypeParams(globalFunctionSymbolJson, symbolgraph));
}

List<GenericType> parseFunctionTypeParams(
  Json globalFunctionSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  // get type params
  final genericInfo = globalFunctionSymbolJson['swiftGenerics'];

  final parameters = genericInfo['parameters'];

  if (genericInfo.jsonWithKeyExists('constraints')) {
    return parameters.map((e) {
      return parseFunctionGenericType(genericInfo, e['name'].get<String>(), 
        symbolgraph, globalFunctionSymbolJson);
    }).toList();
  } else {
    // how to make a good id for generic types
    return parameters
        .map((e) => GenericType(
            id: e['name'].get<String>(), name: e['name'].get<String>()))
        .toList();
  }
}

GenericType parseFunctionGenericType(Json genericInfo, String name, 
    ParsedSymbolgraph symbolgraph, 
    Json functionSymbolJson, {String? id}) {
  final constraintsDesc = genericInfo['constraints'].where(
      (element) => element['lhs'].get<String>() == name);
  
  return GenericType(
      id: id ?? name,
      name: name,
      constraints: constraintsDesc.map((c) {
        final constraintId = c['rhsPrecise'].get<String>();
  
        final constraintTypeSymbol = symbolgraph.symbols[constraintId];
  
        if (constraintTypeSymbol == null) {
          throw Exception(
            'The type constraint at path "${functionSymbolJson.path}"'
            ' has a return type that does not exist among parsed symbols.',
          );
        }
  
        final constraintDeclaration = parseDeclaration(
          constraintTypeSymbol,
          symbolgraph,
        ) as CompoundDeclaration;
  
        return constraintDeclaration.asDeclaredType;
      }).toList());
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
    typeParams: parseFunctionTypeParams(methodSymbolJson, symbolgraph),
    isStatic: isStatic,
  );
}

ReferredType? _parseFunctionReturnType(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final returnJson = methodSymbolJson['functionSignature']['returns'][0];

  // if it is a type generic it may not even have a spelling
  if (returnJson['spelling'].get<String?>() == null) {
    // check if the item is a generic registered
    try {
      final type = returnJson['spelling'].get<String>();
      final generics = methodSymbolJson['swiftGenerics']['parameters'];
      if (generics.map((e) => e['name'].get<String>()).contains(type)) {
        // generic located
        return parseFunctionGenericType(methodSymbolJson['swiftGenerics'], type,
          symbolgraph, methodSymbolJson);
      }
    } on Exception catch (e) {
      // continue
    }
  } else if (returnJson['spelling'].get<String>() == '()') {
    // This means there's no return type
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
        // TODO: Add parameter type generic parsing
        (param) => Parameter(
          name: param['name'].get(),
          internalName: param['internalName'].get(),
          type: _parseParamType(param, symbolgraph, methodSymbolJson: methodSymbolJson),
        ),
      )
      .toList();
}

ReferredType _parseParamType(
  Json paramSymbolJson,
  ParsedSymbolgraph symbolgraph,
  {Json? methodSymbolJson}
) {
  final fragments = paramSymbolJson['declarationFragments'];

  var typeDeclFragment = fragments
      .firstJsonWhereKey('kind', 'typeIdentifier');
  
  if (methodSymbolJson != null) {
    if (methodSymbolJson['swiftGenerics'].get<Map<String, dynamic>?>() != null) {
      if (methodSymbolJson['swiftGenerics']['parameters'].map(
            (e) => e['name'].get<String>()
          ).contains(typeDeclFragment['spelling'].get<String>())) {
        return parseFunctionGenericType(methodSymbolJson['swiftGenerics'], 
          typeDeclFragment['spelling'].get<String>(), symbolgraph, 
          methodSymbolJson);
      }
    }
  }

  final paramTypeId = typeDeclFragment['preciseIdentifier']
      .get<String>();

  return parseTypeFromId(paramTypeId, symbolgraph);
}
