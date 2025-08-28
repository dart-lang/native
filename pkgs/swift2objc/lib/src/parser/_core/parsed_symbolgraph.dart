// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../config.dart';
import 'json.dart';

typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef ParsedRelationsMap = Map<String, Map<String, ParsedRelation>>;

final class SymbolIdCollisionError extends ArgumentError {
  SymbolIdCollisionError(ParsedSymbol symbol1, ParsedSymbol symbol2)
    : super('''
Two different symbols have the same ID:
${symbol1.json}
${symbol2.json}
''');
}

class ParsedSymbolgraph {
  final ParsedSymbolsMap symbols;
  final ParsedRelationsMap relations;

  ParsedSymbolgraph({ParsedSymbolsMap? symbols, ParsedRelationsMap? relations})
    : symbols = symbols ?? builtInSymbolsMap(),
      relations = relations ?? {};

  /// Merge other into this.
  ///
  /// Throws if there are symbols with the same ID that aren't identical. When
  /// deduping, the existing symbol or relation is always kept.
  void merge(ParsedSymbolgraph other) {
    // Dedupe the symbols by ID. If two symbols with the same ID have different
    // JSON encodings, throw an error.
    for (final MapEntry(key: id, value: symbol) in other.symbols.entries) {
      final old = symbols[id];
      if (old != null) {
        if (old.json.exists && old.json.toString() != symbol.json.toString()) {
          throw SymbolIdCollisionError(old, symbol);
        }
      } else {
        symbols[id] = symbol;
      }
    }

    // Each symbol (and pair of symbols) can have multiple relations, so don't
    // dedupe by ID. Instead dedupe by the json encoding of the relation.
    for (final MapEntry(key: id, value: relationMap)
        in other.relations.entries) {
      final dest = relations[id] ??= {};
      for (final MapEntry(key: json, value: relation) in relationMap.entries) {
        dest[json] = relation;
      }
    }
  }

  static ParsedSymbolsMap builtInSymbolsMap() => {
    for (final decl in builtInDeclarations)
      decl.id: ParsedSymbol(source: null, json: Json(null), declaration: decl),
  };
}

class ParsedSymbol {
  final InputConfig? source;
  final Json json;
  Declaration? declaration;

  ParsedSymbol({required this.source, required this.json, this.declaration});
}

class ParsedRelation {
  final InputConfig source;
  final Json json;
  final ParsedRelationKind kind;
  final String sourceId;
  final String targetId;

  ParsedRelation({
    required this.source,
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
