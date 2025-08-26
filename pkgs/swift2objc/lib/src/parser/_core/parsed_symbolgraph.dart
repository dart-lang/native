// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import 'json.dart';

typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef ParsedRelationsMap = Map<String, Map<String, ParsedRelation>>;

class ParsedSymbolgraph {
  final ParsedSymbolsMap symbols;
  final ParsedRelationsMap relations;

  ParsedSymbolgraph({ParsedSymbolsMap? symbols, ParsedRelationsMap? relations})
    : symbols = symbols ?? {},
      relations = relations ?? {};

  /// Merge other into this.
  ///
  /// Throws if there are symbols with the same ID that aren't identical.
  void merge(ParsedSymbolgraph other) {
    for (final MapEntry(key: id, value: symbol) in other.symbols.entries) {
      if (symbols.containsKey(id)) {
        // TODO: Throw a more useful error.
        assert(symbols[id]!.json.toString() == symbol.json.toString());
      } else {
        symbols[id] = symbol;
      }
    }

    for (final MapEntry(key: id, value: relationMap)
        in other.relations.entries) {
      final dest = relations[id] ??= {};
      for (final MapEntry(key: encoded, value: relation) in relationMap.entries) {
        dest[encoded] ??= relation;
      }
    }
  }
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
  memberOf;

  static final _supportedRelationKindsMap = {
    for (final relationKind in ParsedRelationKind.values)
      relationKind.name: relationKind,
  };

  static ParsedRelationKind? fromString(String relationKindString) =>
      _supportedRelationKindsMap[relationKindString];
}
