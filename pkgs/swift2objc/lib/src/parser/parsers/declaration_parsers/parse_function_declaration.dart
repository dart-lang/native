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
  final info = parseFunctionInfo(
      globalFunctionSymbolJson['declarationFragments'], symbolgraph);
  return GlobalFunctionDeclaration(
    id: parseSymbolId(globalFunctionSymbolJson),
    name: parseSymbolName(globalFunctionSymbolJson),
    returnType: _parseFunctionReturnType(globalFunctionSymbolJson, symbolgraph),
    params: info.params,
    throws: info.throws,
    async: info.async,
  );
}

MethodDeclaration parseMethodDeclaration(
  Json methodSymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final info =
      parseFunctionInfo(methodSymbolJson['declarationFragments'], symbolgraph);
  return MethodDeclaration(
    id: parseSymbolId(methodSymbolJson),
    name: parseSymbolName(methodSymbolJson),
    returnType: _parseFunctionReturnType(methodSymbolJson, symbolgraph),
    params: info.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(methodSymbolJson),
    isStatic: isStatic,
    throws: info.throws,
    async: info.async,
  );
}

typedef ParsedFunctionInfo = ({
  List<Parameter> params,
  bool throws,
  bool async,
});

ParsedFunctionInfo parseFunctionInfo(
  Json declarationFragments,
  ParsedSymbolgraph symbolgraph,
) {
  // `declarationFragments` describes each part of the function declaration,
  // things like the `func` keyword, brackets, spaces, etc. We only care about
  // the parameter fragments and annotations here, and they always appear in
  // this order:
  // [
  //   ..., '(',
  //   externalParam, ' ', internalParam, ': ', type..., ', '
  //   externalParam, ': ', type..., ', '
  //   externalParam, ' ', internalParam, ': ', type..., ')'
  //   annotations..., '->', returnType...
  // ]
  // Note: `internalParam` may or may not exist.
  //
  // The following loop attempts to extract parameters from this flat array
  // while making sure the parameter fragments have the expected order.

  final parameters = <Parameter>[];
  final malformedInitializerException = Exception(
    'Malformed parameter list at ${declarationFragments.path}: '
    '$declarationFragments',
  );

  var tokens = TokenList(declarationFragments);
  String? maybeConsume(String kind) {
    if (tokens.isEmpty) return null;
    final spelling = getSpellingForKind(tokens[0], kind);
    if (spelling != null) tokens = tokens.slice(1);
    return spelling;
  }

  final openParen = tokens.indexWhere((tok) => matchFragment(tok, 'text', '('));
  if (openParen == -1) throw malformedInitializerException;
  tokens = tokens.slice(openParen + 1);

  // Parse parameters until we find a ')'.
  if (maybeConsume('text') == ')') {
    // Empty param list.
  } else {
    while (true) {
      final externalParam = maybeConsume('externalParam');
      if (externalParam == null) throw malformedInitializerException;

      var sep = maybeConsume('text');
      String? internalParam;
      if (sep == '') {
        internalParam = maybeConsume('internalParam');
        if (internalParam == null) throw malformedInitializerException;
        sep = maybeConsume('text');
      }

      if (sep != ':') throw malformedInitializerException;
      final (type, remainingTokens) = parseType(symbolgraph, tokens);
      tokens = remainingTokens;

      parameters.add(Parameter(
        name: externalParam,
        internalName: internalParam,
        type: type,
      ));

      final end = maybeConsume('text');
      if (end == ')') break;
      if (end != ',') throw malformedInitializerException;
    }
  }

  // Parse annotations until we run out. The annotations are keywords separated
  // by whitespace tokens.
  final annotations = <String>{};
  while (true) {
    final keyword = maybeConsume('keyword');
    if (keyword == null) {
      if (maybeConsume('text') != '') break;
    } else {
      annotations.add(keyword);
    }
  }

  return (
    params: parameters,
    throws: annotations.contains('throws'),
    async: annotations.contains('async'),
  );
}

// TODO(https://github.com/dart-lang/native/issues/1931): Function Return Type does not support nested types
//  (e.g String.UTF8, Self.Element
//  (necessary when making use of protocol associated types))
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
