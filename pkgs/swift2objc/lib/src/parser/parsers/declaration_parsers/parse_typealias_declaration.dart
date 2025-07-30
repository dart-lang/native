// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/declarations/typealias_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

TypealiasDeclaration? parseTypealiasDeclaration(
  Json typealiasSymbolJson,
  ParsedSymbolgraph symbolgraph) {
  final id = parseSymbolId(typealiasSymbolJson);
  final name = parseSymbolName(typealiasSymbolJson);
  final declarationFragments = typealiasSymbolJson['declarationFragments'];

  final malformedException = Exception(
    'Malformed typealias at ${declarationFragments.path}: '
    '$declarationFragments',
  );

  final tokens = TokenList(declarationFragments);
  final equals = tokens.indexWhere((tok) => matchFragment(tok, 'text', '='));
  if (equals == -1) throw malformedException;

  final (target, remaining) = parseType(symbolgraph, tokens.slice(equals + 1));
  if (remaining.isNotEmpty) throw malformedException;

  return TypealiasDeclaration(id, name, target);
}
