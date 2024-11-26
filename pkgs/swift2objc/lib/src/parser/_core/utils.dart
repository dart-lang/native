// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/nestable_declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/globals/globals.dart';
import '../parsers/parse_type.dart';
import 'json.dart';
import 'parsed_symbolgraph.dart';
import 'token_list.dart';

typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef ParsedRelationsMap = Map<String, List<ParsedRelation>>;

Json readJsonFile(String jsonFilePath) {
  final jsonStr = File(jsonFilePath).readAsStringSync();
  return Json(jsonDecode(jsonStr));
}

// Valid ID characters seen in symbolgraphs: 0-9A-Za-z_():@
const idDelim = '-';

extension AddIdSuffix on String {
  String addIdSuffix(String suffix) => '$this$idDelim$suffix';
}

extension TopLevelOnly<T extends Declaration> on List<T> {
  List<Declaration> get topLevelOnly => where((declaration) {
        if (declaration is NestableDeclaration) {
          return declaration.nestingParent == null;
        }
        return declaration is GlobalVariableDeclaration ||
            declaration is GlobalFunctionDeclaration;
      }).toList();
}

/// If `fragment['kind'] == kind`, returns `fragment['spelling']`. Otherwise
/// returns null.
String? getSpellingForKind(Json fragment, String kind) =>
    fragment['kind'].get<String?>() == kind
        ? fragment['spelling'].get<String?>()
        : null;

/// Matches fragments, which look like `{"kind": "foo", "spelling": "bar"}`.
bool matchFragment(Json fragment, String kind, String spelling) =>
    getSpellingForKind(fragment, kind) == spelling;

String parseSymbolId(Json symbolJson) {
  final idJson = symbolJson['identifier']['precise'];
  final id = idJson.get<String>();
  assert(
    !id.contains(idDelim),
    'Symbold id at path ${idJson.path} contains a hiphen "$idDelim" '
    'which is not expected',
  );
  return id;
}

String parseSymbolName(Json symbolJson) {
  return symbolJson['declarationFragments']
      .firstJsonWhereKey('kind', 'identifier')['spelling']
      .get();
}

bool parseSymbolHasObjcAnnotation(Json symbolJson) {
  return symbolJson['declarationFragments']
      .any((json) => matchFragment(json, 'attribute', '@objc'));
}

bool parseIsOverriding(Json symbolJson) {
  return symbolJson['declarationFragments']
      .any((json) => matchFragment(json, 'keyword', 'override'));
}

final class ObsoleteException implements Exception {
  final String symbol;
  ObsoleteException(this.symbol);

  @override
  String toString() => '$runtimeType: Symbol is obsolete: $symbol';
}

bool isObsoleted(Json symbolJson) {
  final availability = symbolJson['availability'];
  if (!availability.exists) return false;
  for (final entry in availability) {
    if (entry['domain'].get<String>() == 'Swift' && entry['obsoleted'].exists) {
      return true;
    }
  }
  return false;
}

extension Deduper<T> on Iterable<T> {
  Iterable<T> dedupeBy<K>(K Function(T) id) =>
      <K, T>{for (final t in this) id(t): t}.values;
}

ReferredType parseTypeAfterSeparator(
  TokenList fragments,
  ParsedSymbolgraph symbolgraph,
) {
  // fragments = [..., ': ', type tokens...]
  final separatorIndex =
      fragments.indexWhere((token) => matchFragment(token, 'text', ': '));
  final (type, suffix) =
      parseType(symbolgraph, fragments.slice(separatorIndex + 1));
  assert(suffix.isEmpty, '$suffix');
  return type;
}
