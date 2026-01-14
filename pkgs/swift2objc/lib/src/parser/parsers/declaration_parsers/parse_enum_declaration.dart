// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/enum_declaration.dart';
import '../../../ast/declarations/enums/associated_value_enum_declaration.dart';
import '../../../ast/declarations/enums/normal_enum_declaration.dart';
import '../../../ast/declarations/enums/raw_value_enum_declaration.dart';

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
  enumDecl.cases.addAll(
    excessMembers.removeWhereType<EnumCaseDeclaration>(),
  );
  return enumDecl;
}

EnumCaseDeclaration parseEnumCaseDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
}
