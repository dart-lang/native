// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../../ast/_core/interfaces/availability.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/nestable_declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/globals/globals.dart';
import '../../context.dart';
import '../parsers/parse_type.dart';
import 'json.dart';
import 'parsed_symbolgraph.dart';
import 'token_list.dart';

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
    if (declaration is InnerNestableDeclaration) {
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

String parseSymbolName(Json symbolJson) => symbolJson['declarationFragments']
    .firstJsonWhereKey('kind', 'identifier')['spelling']
    .get();

bool parseSymbolHasObjcAnnotation(Json symbolJson) =>
    symbolJson['declarationFragments'].any(
      (json) => matchFragment(json, 'attribute', '@objc'),
    );

bool parseIsOverriding(Json symbolJson) => symbolJson['declarationFragments']
    .any((json) => matchFragment(json, 'keyword', 'override'));

List<AvailabilityInfo> parseAvailability(Json symbolJson) {
  final availability = symbolJson['availability'];
  if (!availability.exists) return const [];
  return availability
      .map(_parseAvailabilityInfo)
      .where((a) => !a.isEmpty)
      .toList();
}

AvailabilityInfo _parseAvailabilityInfo(Json json) => AvailabilityInfo(
  domain: json['domain'].get(),
  unavailable: json['isUnconditionallyUnavailable'].get<bool?>() ?? false,
  introduced: _parseAvailabilityVersion(json['introduced']),
  deprecated: _parseAvailabilityVersion(json['deprecated']),
  obsoleted: _parseAvailabilityVersion(json['obsoleted']),
);

AvailabilityVersion? _parseAvailabilityVersion(Json json) => !json.exists
    ? null
    : AvailabilityVersion(
        major: json['major'].get(),
        minor: json['minor'].get(),
        patch: json['patch'].get(),
      );

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

extension Remover<T> on List<T> {
  List<U> removeWhereType<U>() {
    final removed = <U>[];
    removeWhere((t) {
      if (t is U) {
        removed.add(t);
        return true;
      }
      return false;
    });
    return removed;
  }
}

ReferredType parseTypeAfterSeparator(
  Context context,
  TokenList fragments,
  ParsedSymbolgraph symbolgraph,
) {
  // fragments = [..., ': ', type tokens...]
  final separatorIndex = fragments.indexWhere(
    (token) => matchFragment(token, 'text', ':'),
  );
  final (type, suffix) = parseType(
    context,
    symbolgraph,
    fragments.slice(separatorIndex + 1),
  );
  assert(suffix.isEmpty, '$suffix');
  return type;
}
