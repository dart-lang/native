// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/availability.dart';
import '../../../ast/declarations/compounds/enum_declaration.dart';
import '../../../config.dart';
import '../../../context.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import 'parse_compound_declaration.dart';
import 'parse_function_declaration.dart';

EnumDeclaration parseEnumDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
  final (compound: enumDecl, :excessMembers) = parseCompoundDeclaration(
    context,
    symbol,
    symbolgraph,
    ({
      required String id,
      required String name,
      required InputConfig? source,
      required List<AvailabilityInfo> availability,
    }) => EnumDeclaration(
      id: id,
      name: name,
      source: source,
      availability: availability,
      cases: [],
      properties: [],
      methods: [],
      initializers: [],
      nestedDeclarations: [],
    ),
  );
  enumDecl.cases.addAll(excessMembers.removeWhereType<EnumCaseDeclaration>());
  return enumDecl;
}

EnumCaseDeclaration parseEnumCaseDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
  return EnumCaseDeclaration(
    id: parseSymbolId(symbol.json),
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    params:
        parseFunctionInfo(
              context,
              symbol.json['declarationFragments'],
              symbolgraph,
              isEnumCase: true,
            ).params
            .map((param) => EnumCaseParam(name: param.name, type: param.type))
            .toList(),
  );
}
