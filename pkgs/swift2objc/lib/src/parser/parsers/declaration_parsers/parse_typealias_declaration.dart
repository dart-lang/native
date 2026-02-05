// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/declarations/typealias_declaration.dart';
import '../../../context.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

TypealiasDeclaration parseTypealiasDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
  final id = parseSymbolId(symbol.json);
  final name = parseSymbolName(symbol.json);
  final availability = parseAvailability(symbol.json);
  final declarationFragments = symbol.json['declarationFragments'];

  final malformedException = Exception(
    'Malformed typealias at ${declarationFragments.path}: '
    '$declarationFragments',
  );

  final tokens = TokenList(declarationFragments);
  final equals = tokens.indexWhere((tok) => matchFragment(tok, 'text', '='));
  if (equals == -1) throw malformedException;

  final (target, remaining) = parseType(
    context,
    symbolgraph,
    tokens.slice(equals + 1),
  );
  if (remaining.isNotEmpty) throw malformedException;

  return TypealiasDeclaration(
    id: id,
    name: name,
    source: symbol.source,
    availability: availability,
    target: target,
  );
}
