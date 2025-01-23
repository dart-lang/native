// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/declaration.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/associated_type_declaration.dart';
import '../../../ast/declarations/compounds/protocol_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

AssociatedTypeDeclaration parseAssociatedTypeDeclaration(
    Json symbolJson, ParsedSymbolgraph symbolGraph) {
  final id = parseSymbolId(symbolJson);
  final name = parseSymbolName(symbolJson);

  final conformedProtocols = _parseConformedProtocols(symbolJson, symbolGraph);

  return AssociatedTypeDeclaration(
      id: id, name: name, conformedProtocols: conformedProtocols);
}

List<DeclaredType<ProtocolDeclaration>> _parseConformedProtocols(
    Json symbolJson, ParsedSymbolgraph symbolGraph) {
  final conformDecls = <DeclaredType<ProtocolDeclaration>>[];

  final identifierIndex = symbolJson['declarationFragments']
      .toList()
      .indexWhere((t) =>
          t['kind'].get<String>() == 'identifier' &&
          t['spelling'].get<String>() == 'Element');

  if (symbolJson['declarationFragments'].length - 1 > identifierIndex &&
      symbolJson['declarationFragments'][identifierIndex + 1]['spelling']
              .get<String>()
              .trim() ==
          ':') {
    // the associated type contains
    final conformList = symbolJson['declarationFragments']
        .toList()
        .sublist(identifierIndex + 2);
    conformList.removeWhere((t) => t['spelling'].get<String>().trim() == ',');

    // go through and find, then add
    for (final proto in conformList) {
      final protoId = proto['preciseIdentifier'].get<String>();

      final protoSymbol = symbolGraph.symbols[protoId];

      if (protoSymbol == null) {
        // return null;
        continue;
      }

      conformDecls.add(
          (tryParseDeclaration(protoSymbol, symbolGraph) as ProtocolDeclaration)
              .asDeclaredType);
    }
  }

  return conformDecls;
}
