// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/availability.dart';
import '../../../ast/_core/interfaces/compound_declaration.dart';
import '../../../ast/_core/interfaces/nestable_declaration.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/compounds/members/property_declaration.dart';
import '../../../ast/declarations/compounds/struct_declaration.dart';
import '../../../config.dart';
import '../../../context.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

typedef CompoundTearOff<T extends CompoundDeclaration> =
    T Function({
      required String id,
      required String name,
      required InputConfig? source,
      required List<AvailabilityInfo> availability,
    });

typedef ParsedCompound<T> = ({
  T compound,
  List<Declaration> excessMembers,
});

ParsedCompound<T> parseCompoundDeclaration<T extends CompoundDeclaration>(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
  CompoundTearOff<T> tearoffConstructor,
) {
  final compoundId = parseSymbolId(symbol.json);

  final compoundRelations =
      symbolgraph.relations[compoundId]?.values.toList() ?? [];

  final compound = tearoffConstructor(
    id: compoundId,
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
  );

  symbol.declaration = compound;

  final memberDeclarations = compoundRelations
      .where((relation) {
        final isMembershipRelation =
            relation.kind == ParsedRelationKind.memberOf;
        final isMemeberOfCompound = relation.targetId == compoundId;
        return isMembershipRelation && isMemeberOfCompound;
      })
      .map((relation) {
        final memberSymbol = symbolgraph.symbols[relation.sourceId];
        if (memberSymbol == null) {
          return null;
        }
        return tryParseDeclaration(context, memberSymbol, symbolgraph);
      })
      .nonNulls
      .dedupeBy((decl) => decl.id)
      .toList();

  compound.methods.addAll(
    memberDeclarations.removeWhereType<MethodDeclaration>().dedupeBy(
      (m) => m.fullName,
    ),
  );
  compound.properties.addAll(
    memberDeclarations.removeWhereType<PropertyDeclaration>(),
  );
  compound.initializers.addAll(
    memberDeclarations.removeWhereType<InitializerDeclaration>().dedupeBy(
      (m) => m.fullName,
    ),
  );
  compound.nestedDeclarations.addAll(
    memberDeclarations.removeWhereType<InnerNestableDeclaration>(),
  );

  compound.nestedDeclarations.fillNestingParents(compound);

  return (compound, memberDeclarations);
}

ClassDeclaration parseClassDeclaration(
  Context context,
  ParsedSymbol classSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  return parseCompoundDeclaration(
    context,
    classSymbol,
    symbolgraph,
    ({
      required String id,
      required String name,
      required InputConfig? source,
      required List<AvailabilityInfo> availability,
    }) => ClassDeclaration(
      id: id,
      name: name,
      source: source,
      availability: availability,
      properties: [],
      methods: [],
      initializers: [],
      nestedDeclarations: [],
    ),
  ).compound;
}

StructDeclaration parseStructDeclaration(
  Context context,
  ParsedSymbol classSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  return parseCompoundDeclaration(
    context,
    classSymbol,
    symbolgraph,
    ({
      required String id,
      required String name,
      required InputConfig? source,
      required List<AvailabilityInfo> availability,
    }) => StructDeclaration(
      id: id,
      name: name,
      source: source,
      availability: availability,
      properties: [],
      methods: [],
      initializers: [],
      nestedDeclarations: [],
    ),
  ).compound;
}
