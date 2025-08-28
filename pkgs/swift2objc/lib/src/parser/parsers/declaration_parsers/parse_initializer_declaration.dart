// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import 'parse_function_declaration.dart';

InitializerDeclaration parseInitializerDeclaration(
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
  final id = parseSymbolId(symbol.json);

  // Initializers don't have `functionSignature` field in symbolgraph like
  // methods do, so we have our only option is to use `declarationFragments`.
  final declarationFragments = symbol.json['declarationFragments'];

  // All initializers should start with an `init` keyword.
  if (!matchFragment(declarationFragments[0], 'keyword', 'init')) {
    throw Exception('Invalid initializer at ${declarationFragments.path}: $id');
  }

  final info = parseFunctionInfo(declarationFragments, symbolgraph);

  return InitializerDeclaration(
    id: id,
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    params: info.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(symbol.json),
    isOverriding: parseIsOverriding(symbol.json),
    isFailable: parseIsFailableInit(id, declarationFragments),
    throws: info.throws,
    async: info.async,
  );
}

bool parseIsFailableInit(String id, Json declarationFragments) =>
    matchFragment(declarationFragments[1], 'text', '?(');
