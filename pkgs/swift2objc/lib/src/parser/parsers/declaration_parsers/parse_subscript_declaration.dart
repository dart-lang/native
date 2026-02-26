// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/subscript_declaration.dart';
import '../../../context.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';
import 'parse_function_declaration.dart';

SubscriptDeclaration parseSubscriptDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final functionInfo = parseFunctionInfo(
    context,
    symbol.json['declarationFragments'],
    symbolgraph,
    isSubscript: true,
  );
  final hasSetter = _hasSetter(symbol.json['declarationFragments']);

  return SubscriptDeclaration(
    id: parseSymbolId(symbol.json),
    source: symbol.source,
    lineNumber: parseLineNumber(symbol.json),
    availability: parseAvailability(symbol.json),
    returnType: _parseSubscriptReturnType(context, symbol.json, symbolgraph),
    params: functionInfo.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(symbol.json),
    isStatic: isStatic,
    throws: functionInfo.throws,
    async: functionInfo.async,
    mutating: functionInfo.mutating,
    hasSetter: hasSetter,
    getter: null,
    setter: null,
  );
}

bool _hasSetter(Json fragments) {
  return fragments.any((frag) => matchFragment(frag, 'keyword', 'set'));
}

ReferredType _parseSubscriptReturnType(
  Context context,
  Json symbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  // Subscripts usually have the return type in functionSignature -> returns
  final returnJson = TokenList(symbolJson['functionSignature']['returns']);
  final (returnType, unparsed) = parseType(context, symbolgraph, returnJson);
  assert(unparsed.isEmpty, '$returnJson\n\n$returnType\n\n$unparsed\n');
  return returnType;
}
