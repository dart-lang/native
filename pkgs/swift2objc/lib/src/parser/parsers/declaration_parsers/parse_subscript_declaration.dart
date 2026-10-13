// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/declarations/compounds/members/subscript_declaration.dart';
import '../../../context.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import 'parse_function_declaration.dart';

SubscriptDeclaration parseSubscriptDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final declarationFragments = symbol.json['declarationFragments'];
  final info = parseFunctionInfo(
    context,
    declarationFragments,
    symbolgraph,
    isSubscript: true,
  );
  return SubscriptDeclaration(
    id: parseSymbolId(symbol.json),
    source: symbol.source,
    lineNumber: parseLineNumber(symbol.json),
    availability: parseAvailability(symbol.json),
    returnType: parseReturnType(context, symbol.json, symbolgraph),
    params: info.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(symbol.json),
    isStatic: isStatic,
    throws: info.throws,
    async: info.async,
    mutating: info.mutating,
    hasSetter: findKeywordInFragments(declarationFragments, 'set'),
  );
}
