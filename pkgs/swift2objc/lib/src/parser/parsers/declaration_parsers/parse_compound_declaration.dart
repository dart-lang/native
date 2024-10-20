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
  required List<MethodDeclaration> methods,
  required List<PropertyDeclaration> properties,
  required List<InitializerDeclaration> initializers,
  required List<String> pathComponents,
});

T _parseCompoundDeclaration<T extends CompoundDeclaration>(
  Json compoundSymbolJson,
  CompoundTearOff<T> tearoffConstructor,
  ParsedSymbolgraph symbolgraph,
) {
  final compoundId = parseSymbolId(compoundSymbolJson);

  final compoundRelations = symbolgraph.relations[compoundId] ?? [];

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

  return tearoffConstructor(
    id: compoundId,
    name: parseSymbolName(compoundSymbolJson),
    methods: memberDeclarations.whereType<MethodDeclaration>().toList(),
    properties: memberDeclarations.whereType<PropertyDeclaration>().toList(),
    initializers:
        memberDeclarations.whereType<InitializerDeclaration>().toList(),
    pathComponents: _parseCompoundPathComponents(compoundSymbolJson),
  );
}

List<String> _parseCompoundPathComponents(Json compoundSymbolJson) =>
    compoundSymbolJson['pathComponents'].get();

ClassDeclaration parseClassDeclaration(
  Json classSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return _parseCompoundDeclaration(
    classSymbolJson,
    ClassDeclaration.new,
    symbolgraph,
  );
}

StructDeclaration parseStructDeclaration(
  Json classSymbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  return _parseCompoundDeclaration(
    classSymbolJson,
    StructDeclaration.new,
    symbolgraph,
  );
}
