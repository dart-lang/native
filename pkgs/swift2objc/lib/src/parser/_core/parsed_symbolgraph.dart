// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import 'json.dart';

typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef ParsedRelationsMap = Map<String, List<ParsedRelation>>;

class ParsedSymbolgraph {
  final ParsedSymbolsMap symbols;
  final ParsedRelationsMap relations;

  ParsedSymbolgraph({ParsedSymbolsMap? symbols, ParsedRelationsMap? relations})
      : symbols = symbols ?? {},
        relations = relations ?? {};

  /// Merge other into this.
  ///
  /// Throws if there are symbols or relations with the same ID that aren't
  /// identical.
  void merge(ParsedSymbolgraph other) {
    for (final MapEntry(key: id, value: symbol) in other.symbols.entries) {
      if (symbols.containsKey(id)) {
        // TODO: Throw a more useful error.
        // TODO: Store the encoded json somewhere so we don't have to constantly
        // re-encode it.
        assert(symbols[id]!.json.toString() == symbol.json.toString());
      } else {
        symbols[id] = symbol;
      }
    }

    for (final MapEntry(key: id, value: relationList)
        in other.relations.entries) {
      final dest = relations[id] ??= [];
      for (final relation in relationList) {
        // TODO: Change the way relations are stored to avoid O(n) scan here.
        final relationJson = relation.json.toString();
        if (!dest.any((r) => r.json.toString() == relationJson)) {
          dest.add(relation);
        }
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
      relationKind.name: relationKind
  };

  static ParsedRelationKind? fromString(String relationKindString) =>
      _supportedRelationKindsMap[relationKindString];
}
