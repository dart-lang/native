// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/globals/globals.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

GlobalFunctionDeclaration parseGlobalFunctionDeclaration(
  Json globalFunctionSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return GlobalFunctionDeclaration(
    id: parseSymbolId(globalFunctionSymbolJson),
    name: parseSymbolName(globalFunctionSymbolJson),
    returnType: _parseFunctionReturnType(globalFunctionSymbolJson, symbolgraph),
    params: parseFunctionParams(
        globalFunctionSymbolJson['declarationFragments'], symbolgraph),
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
    params: parseFunctionParams(
        methodSymbolJson['declarationFragments'], symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(methodSymbolJson),
    isStatic: isStatic,
  );
}

List<Parameter> parseFunctionParams(
  Json declarationFragments,
  ParsedSymbolgraph symbolgraph,
) {
  // `declarationFragments` describes each part of the initializer declaration,
  // things like the `func` keyword, brackets, spaces, etc. We only care about
  // the parameter fragments here, and they always appear in this order:
  // [
  //   ..., '(',
  //   externalParam, ' ', internalParam, ': ', type..., ', '
  //   externalParam, ': ', type..., ', '
  //   externalParam, ' ', internalParam, ': ', type..., ')'
  // ]
  // Note: `internalParam` may or may not exist.
  //
  // The following loop attempts to extract parameters from this flat array
  // while making sure the parameter fragments have the expected order.

  final parameters = <Parameter>[];

  var tokens = TokenList(declarationFragments);
  final openParen = tokens.indexWhere((tok) => matchFragment(tok, 'text', '('));
  if (openParen != -1) {
    tokens = tokens.slice(openParen + 1);
    String? consume(String kind) {
      if (tokens.isEmpty) return null;
      final token = tokens[0];
      tokens = tokens.slice(1);
      return getSpellingForKind(token, kind);
    }

    final malformedInitializerException = Exception(
      'Malformed initializer at ${declarationFragments.path}',
    );
    while (true) {
      final externalParam = consume('externalParam');
      if (externalParam == null) throw malformedInitializerException;

      var sep = consume('text');
      String? internalParam;
      if (sep == ' ') {
        internalParam = consume('internalParam');
        if (internalParam == null) throw malformedInitializerException;
        sep = consume('text');
      }

      if (sep != ': ') throw malformedInitializerException;
      final (type, remainingTokens) = parseType(symbolgraph, tokens);
      tokens = remainingTokens;

      parameters.add(Parameter(
        name: externalParam,
        internalName: internalParam,
        type: type,
      ));

      final end = consume('text');
      if (end == ')') break;
      if (end != ', ') throw malformedInitializerException;
    }
    if (!(tokens.isEmpty || consume('text') == '->')) {
      throw malformedInitializerException;
    }
  }

  return parameters;
}

ReferredType _parseFunctionReturnType(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final returnJson =
      TokenList(methodSymbolJson['functionSignature']['returns']);
  final (returnType, unparsed) = parseType(symbolgraph, returnJson);
  assert(unparsed.isEmpty, '$returnJson\n\n$returnType\n\n$unparsed\n');
  return returnType;
}
