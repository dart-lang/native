// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import 'json.dart';
import 'utils.dart';

class ParsedSymbolgraph {
  final ParsedSymbolsMap symbols;
  final ParsedRelationsMap relations;

  ParsedSymbolgraph(this.symbols, this.relations);
}

class ParsedSymbol {
  Json json;
  Declaration? declaration;

  ParsedSymbol({required this.json, this.declaration});
}

class ParsedRelation {
  final Json json;
  final ParsedRelationKind kind;
  final String sourceId;
  final String targetId;

  ParsedRelation({
    required this.kind,
    required this.sourceId,
    required this.targetId,
    required this.json,
  });
}

enum ParsedRelationKind {
  requirementOf,
  defaultImplementationOf,
  optionalRequirementOf,
  conformsTo,
  memberOf;

  static final _supportedRelationKindsMap = {
    for (final relationKind in ParsedRelationKind.values)
      relationKind.name: relationKind
  };

  static ParsedRelationKind? fromString(String relationKindString) =>
      _supportedRelationKindsMap[relationKindString];
}
