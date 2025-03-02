// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/compound_declaration.dart';
import '../../../ast/_core/interfaces/declaration.dart';
import '../../../ast/_core/interfaces/nestable_declaration.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../../ast/declarations/compounds/members/associated_type_declaration.dart';
import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/compounds/members/property_declaration.dart';
import '../../../ast/declarations/compounds/protocol_declaration.dart';
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
          return tryParseDeclaration(memberSymbol, symbolgraph);
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
  compound.nestedDeclarations.addAll(
    memberDeclarations.whereType<NestableDeclaration>(),
  );

  compound.nestedDeclarations.fillNestingParents(compound);

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

// TODO(https://github.com/dart-lang/native/issues/1815): Implement extensions before adding support for default implementations
ProtocolDeclaration parseProtocolDeclaration(
    ParsedSymbol protocolSymbol, ParsedSymbolgraph symbolgraph) {
  final compoundId = parseSymbolId(protocolSymbol.json);
  final compoundRelations = symbolgraph.relations[compoundId] ?? [];

  // construct protocol
  final protocol = ProtocolDeclaration(
      id: compoundId,
      name: parseSymbolName(protocolSymbol.json),
      properties: [],
      methods: [],
      initializers: [],
      conformedProtocols: []);

  // get optional member declarations if any
  final optionalMemberDeclarations = compoundRelations
      .where((relation) {
        final isOptionalRequirementRelation =
            relation.kind == ParsedRelationKind.optionalRequirementOf;
        final isMemberOfProtocol = relation.targetId == compoundId;
        return isMemberOfProtocol && isOptionalRequirementRelation;
      })
      .map((relation) {
        final memberSymbol = symbolgraph.symbols[relation.sourceId];
        if (memberSymbol == null) {
          return null;
        }
        return tryParseDeclaration(memberSymbol, symbolgraph);
      })
      .nonNulls
      .dedupeBy((decl) => decl.id)
      .toList();

  // get normal member declarations
  final memberDeclarations = compoundRelations
      .where((relation) {
        final isOptionalRequirementRelation =
            relation.kind == ParsedRelationKind.requirementOf &&
                relation.kind != ParsedRelationKind.optionalRequirementOf;
        final isMemberOfProtocol = relation.targetId == compoundId;
        return isMemberOfProtocol && isOptionalRequirementRelation;
      })
      .map((relation) {
        final memberSymbol = symbolgraph.symbols[relation.sourceId];

        if (memberSymbol == null) {
          return null;
        }

        return tryParseDeclaration(memberSymbol, symbolgraph);
      })
      .nonNulls
      .dedupeBy((decl) => decl.id)
      .toList();

  // get conformed protocols
  final conformedProtocolDeclarations = compoundRelations
      .where((relation) {
        final isOptionalRequirementRelation =
            relation.kind == ParsedRelationKind.conformsTo;
        final isMemberOfProtocol = relation.sourceId == compoundId;
        return isMemberOfProtocol && isOptionalRequirementRelation;
      })
      .map((relation) {
        final memberSymbol = symbolgraph.symbols[relation.targetId];
        if (memberSymbol == null) {
          return null;
        }
        var conformedDecl = tryParseDeclaration(memberSymbol, symbolgraph)
            as ProtocolDeclaration;
        return conformedDecl.asDeclaredType;
      })
      .nonNulls
      .dedupeBy((decl) => decl.id)
      .toList();

  // If the protocol has optional members, it must be annotated with `@objc`
  if (optionalMemberDeclarations.isNotEmpty) {
    protocol.hasObjCAnnotation = true;
  }

  protocol.associatedTypes.addAll(memberDeclarations
      .whereType<AssociatedTypeDeclaration>()
      .map((decl) => decl.asType())
      .dedupeBy((m) => m.name));

  protocol.methods.addAll(
    memberDeclarations
        .whereType<MethodDeclaration>()
        .dedupeBy((m) => m.fullName),
  );

  protocol.properties.addAll(
    memberDeclarations.whereType<PropertyDeclaration>(),
  );

  protocol.optionalMethods.addAll(
    optionalMemberDeclarations
        .whereType<MethodDeclaration>()
        .dedupeBy((m) => m.fullName),
  );

  protocol.optionalProperties.addAll(
    optionalMemberDeclarations.whereType<PropertyDeclaration>(),
  );

  protocol.conformedProtocols.addAll(conformedProtocolDeclarations);

  protocol.initializers.addAll(
    memberDeclarations
        .whereType<InitializerDeclaration>()
        .dedupeBy((m) => m.fullName),
  );

  protocol.nestedDeclarations.addAll(
    memberDeclarations.whereType<NestableDeclaration>(),
  );

  protocol.nestedDeclarations.fillNestingParents(protocol);

  return protocol;
}
