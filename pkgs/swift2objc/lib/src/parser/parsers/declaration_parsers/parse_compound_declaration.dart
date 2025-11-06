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
      required List<PropertyDeclaration> properties,
      required List<MethodDeclaration> methods,
      required List<InitializerDeclaration> initializers,
      required List<InnerNestableDeclaration> nestedDeclarations,
    });

T _parseCompoundDeclaration<T extends CompoundDeclaration>(
  Context context,
  ParsedSymbol symbol,
  CompoundTearOff<T> tearoffConstructor,
  ParsedSymbolgraph symbolgraph,
) {
  final compoundId = parseSymbolId(symbol.json);

  final compoundRelations =
      symbolgraph.relations[compoundId]?.values.toList() ?? [];

  final compound = tearoffConstructor(
    id: compoundId,
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    methods: [],
    properties: [],
    initializers: [],
    nestedDeclarations: [],
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
    memberDeclarations.whereType<MethodDeclaration>().dedupeBy(
      (m) => m.fullName,
    ),
  );
  compound.properties.addAll(
    memberDeclarations.whereType<PropertyDeclaration>(),
  );
  compound.initializers.addAll(
    memberDeclarations.whereType<InitializerDeclaration>().dedupeBy(
      (m) => m.fullName,
    ),
  );
  compound.nestedDeclarations.addAll(
    memberDeclarations.whereType<InnerNestableDeclaration>(),
  );

  compound.nestedDeclarations.fillNestingParents(compound);

  return compound;
}

ClassDeclaration parseClassDeclaration(
  Context context,
  ParsedSymbol classSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  return _parseCompoundDeclaration(
    context,
    classSymbol,
    ClassDeclaration.new,
    symbolgraph,
  );
}

StructDeclaration parseStructDeclaration(
  Context context,
  ParsedSymbol classSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  return _parseCompoundDeclaration(
    context,
    classSymbol,
    StructDeclaration.new,
    symbolgraph,
  );
}
