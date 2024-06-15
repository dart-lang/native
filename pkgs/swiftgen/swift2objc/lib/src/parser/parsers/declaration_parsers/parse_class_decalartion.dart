// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';
import 'package:swift2objc/src/parser/parsers/parse_declarations_map.dart';

import '../../../ast/declarations/compounds/class_declaration.dart';
import '../../_core/utils.dart';

ClassDeclaration parseClassDeclaration(
  Json symbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final classId = parseSymbolId(symbolJson);

  final classRelations = symbolgraph.relations[classId] ?? [];

  final memberDeclarations = classRelations.where(
    (relation) {
      final isMembershipRelation = relation.kind == ParsedRelationKind.memberOf;
      final isMemeberOfClass = relation.targetId == classId;
      return isMembershipRelation && isMemeberOfClass;
    },
  ).map(
    (relation) {
      final memberSymbol = symbolgraph.symbols[relation.sourceId];
      if (memberSymbol == null) {
        throw 'Symbol of id "${relation.sourceId}" exist in a relation at path "${relation.json.path}" but does not exist among parsed symbols.';
      }
      return parseDeclaration(memberSymbol, symbolgraph);
    },
  );

  return ClassDeclaration(
    id: parseSymbolId(symbolJson),
    name: parseSymbolName(symbolJson),
    methods: memberDeclarations.whereType<ClassMethodDeclaration>().toList(),
    properties:
        memberDeclarations.whereType<ClassPropertyDeclaration>().toList(),
  );
}
