// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/compound_declaration.dart';
import '../../../ast/_core/interfaces/nestable_declaration.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/compounds/members/property_declaration.dart';
import '../../../ast/declarations/compounds/struct_declaration.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

typedef CompoundTearOff<T extends CompoundDeclaration> = T Function({
  required String id,
  required String name,
  required List<PropertyDeclaration> properties,
  required List<MethodDeclaration> methods,
  required List<InitializerDeclaration> initializers,
  required List<NestableDeclaration> nestedDeclarations,
});

T _parseCompoundDeclaration<T extends CompoundDeclaration>(
  ParsedSymbol compoundSymbol,
  CompoundTearOff<T> tearoffConstructor,
  ParsedSymbolgraph symbolgraph,
) {
  final compoundId = parseSymbolId(compoundSymbol.json);
  final debug = compoundId == "c:objc(cs)AVAudioPlayer";
  if (debug) print("\nQQQQ");

  final compoundRelations = symbolgraph.relations[compoundId] ?? [];

  final compound = tearoffConstructor(
    id: compoundId,
    name: parseSymbolName(compoundSymbol.json),
    methods: [],
    properties: [],
    initializers: [],
    nestedDeclarations: [],
  );

  compoundSymbol.declaration = compound;

  final memberDeclarations = compoundRelations
      .where(
        (relation) {
          final isMembershipRelation =
              relation.kind == ParsedRelationKind.memberOf;
          final isMemeberOfCompound = relation.targetId == compoundId;
          return isMembershipRelation && isMemeberOfCompound;
        },
      )
      .map(
        (relation) {
          final memberSymbol = symbolgraph.symbols[relation.sourceId];
          if (memberSymbol == null) {
            return null;
          }
          final decl = tryParseDeclaration(memberSymbol, symbolgraph, debug: debug);

          if (debug) print("\t\t${relation.sourceId}\t${decl?.id}");
          return decl;
        },
      )
      .nonNulls
      .dedupeBy((decl) => decl.id)
      .toList();

  compound.methods.addAll(
    memberDeclarations
        .whereType<MethodDeclaration>()
        .dedupeBy((m) => m.fullName),
  );
  compound.properties.addAll(
    memberDeclarations.whereType<PropertyDeclaration>(),
  );
  compound.initializers.addAll(
    memberDeclarations
        .whereType<InitializerDeclaration>()
        .dedupeBy((m) => m.fullName),
  );
  if (debug) print(compound.initializers.map((i) => i.id).toList());
  compound.nestedDeclarations.addAll(
    memberDeclarations.whereType<NestableDeclaration>(),
  );

  compound.nestedDeclarations.fillNestingParents(compound);

  if (debug) print("\n");

  return compound;
}

ClassDeclaration parseClassDeclaration(
  ParsedSymbol classSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  return _parseCompoundDeclaration(
    classSymbol,
    ClassDeclaration.new,
    symbolgraph,
  );
}

StructDeclaration parseStructDeclaration(
  ParsedSymbol classSymbol,
  ParsedSymbolgraph symbolgraph,
) {
  return _parseCompoundDeclaration(
    classSymbol,
    StructDeclaration.new,
    symbolgraph,
  );
}
