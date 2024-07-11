// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/parse_declarations.dart';

import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassMethodDeclaration parseMethodDeclaration(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return ClassMethodDeclaration(
    id: parseSymbolId(methodSymbolJson),
    name: parseSymbolName(methodSymbolJson),
    returnType: _parseMethodReturnType(methodSymbolJson, symbolgraph),
    params: _parseMethodParams(methodSymbolJson, symbolgraph),
  );
}

ReferredType? _parseMethodReturnType(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final returnJson = methodSymbolJson["functionSignature"]["returns"][0];

  // This means there's no return type
  if (returnJson["spelling"].get<String>() == "()") {
    return null;
  }

  final String returnTypeId = returnJson["preciseIdentifier"].get();

  final returnTypeSymbol = symbolgraph.symbols[returnTypeId];

  if (returnTypeSymbol == null) {
    throw 'The method at path "${methodSymbolJson.path}" has a return type that does not exist among parsed symbols.';
  }

  final returnTypeDeclaration = parseDeclaration(
    returnTypeSymbol,
    symbolgraph,
  );

  return DeclaredType(id: returnTypeId, declaration: returnTypeDeclaration);
}

List<Parameter> _parseMethodParams(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final paramList = methodSymbolJson["functionSignature"]["parameters"];

  if (!paramList.exists) return [];

  return paramList
      .map(
        (param) => Parameter(
          name: param["name"].get(),
          internalName: param["internalName"].get(),
          type: _parseParamType(param, symbolgraph),
        ),
      )
      .toList();
}

ReferredType _parseParamType(
  Json paramSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final fragments = paramSymbolJson["declarationFragments"];

  final String paramTypeId = fragments
      .firstWhereKey("kind", "typeIdentifier")["preciseIdentifier"]
      .get();

  final paramTypeSymbol = symbolgraph.symbols[paramTypeId];

  if (paramTypeSymbol == null) {
    throw 'The method param at path "${paramSymbolJson.path}" has a type that does not exist among parsed symbols.';
  }

  final paramTypeDeclaration = parseDeclaration(paramTypeSymbol, symbolgraph);

  return DeclaredType(id: paramTypeId, declaration: paramTypeDeclaration);
}
