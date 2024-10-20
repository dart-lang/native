// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/interfaces/compound_declaration.dart';
import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/compounds/members/property_declaration.dart';
import '../../../ast/declarations/compounds/struct_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';
import '../parse_declarations.dart';

typedef CompoundTearOff<T extends CompoundDeclaration> = T Function({
  required String id,
  required String name,
  required List<String> pathComponents,
  required List<PropertyDeclaration> properties,
  required List<MethodDeclaration> methods,
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
    pathComponents: _parseCompoundPathComponents(compoundSymbol.json),
    methods: [],
    properties: [],
  );

  compoundSymbol.declaration = compound;

  final memberDeclarations = compoundRelations.where(
    (relation) {
      final isMembershipRelation = relation.kind == ParsedRelationKind.memberOf;
      final isMemeberOfCompound = relation.targetId == compoundId;
      return isMembershipRelation && isMemeberOfCompound;
    },
  ).map(
    (relation) {
      final memberSymbol = symbolgraph.symbols[relation.sourceId];
      if (memberSymbol == null) {
        throw Exception(
          'Symbol of id "${relation.sourceId}" exist in a relation at path '
          '"${relation.json.path}" but does not exist among parsed symbols.',
        );
      }
      return parseDeclaration(memberSymbol, symbolgraph);
    },
  );

  compound.methods.addAll(
    memberDeclarations.whereType<MethodDeclaration>(),
  );
  compound.properties.addAll(
    memberDeclarations.whereType<PropertyDeclaration>(),
  );
  compound.initializers.addAll(
    memberDeclarations.whereType<InitializerDeclaration>(),
  );

  return compound;
}

List<String> _parseCompoundPathComponents(Json compoundSymbolJson) =>
    compoundSymbolJson['pathComponents'].get<List<dynamic>>().cast();

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
