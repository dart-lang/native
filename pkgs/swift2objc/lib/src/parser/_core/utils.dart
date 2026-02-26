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

int? parseLineNumber(Json symbolJson) {
  final locationJson = symbolJson['location'];
  if (!locationJson.exists) return null;

  final positionJson = locationJson['position'];
  if (!positionJson.exists) return null;

  final lineJson = positionJson['line'];
  if (!lineJson.exists) return null;

  return lineJson.get<int>();
}

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
  // Or sometimes [..., ': [', type tokens...] if combined.

  // Find the token that contains the separator.
  final separatorIndex = fragments.indexWhere(
    (token) =>
        matchFragment(token, 'text', ':') ||
        (getSpellingForKind(token, 'text')?.startsWith(':') ?? false),
  );

  if (separatorIndex == -1) {
    throw Exception('Could not find separator ":" in fragments: $fragments');
  }

  var suffixFragments = fragments.slice(separatorIndex + 1);

  // If the separator token contained more than just ':', we need to handle the rest.
  // E.g. ': [' -> '['
  final separatorToken = fragments[separatorIndex];
  final spelling = getSpellingForKind(separatorToken, 'text')!;

  if (spelling != ':' && spelling.startsWith(':')) {
    // The token contains more than just colon.
    // We can't easily modify the token in place without copying json.
    // But since we know it starts with ':', the rest is effectively the start of type.
    // However, `parseType` expects the first token to be meaningful.
    // If spelling is ': [', the type starts with '['.
    // Since we can't create a new Json object easily here without deep copy logic or modifying original,
    // we might need a workaround.
    // Assuming the suffix is mostly just simple tokens like '[' or 'typeIdentifier'.

    // Hack: If it is ': [', treat it as '[' by reusing the token but modifying spelling?
    // No, Json is read-only wrapper usually?
    // Actually Json class in `_core/json.dart` might be mutable map wrapper?
    // Let's check `json.dart`.
    // But modifying it might affect other things?
    // Better: parseType takes TokenList. TokenList wraps List<Json>.
    // If we can construct a synthetic Json for the rest of the token?

    // For now, let's assume if it is ': [', we can simulate '[' token.
    // Actually `parseType` handles `text: [` via `_tupleParselet`?
    // No `_prefixParsets` handles `text: (` (tuple).
    // `[` is for Array. Array is usually `[Type]`.
    // There is no `_prefixParsets` for `[`.
    // Wait, Array syntax `[String]` -> `_bracketParselet`?
    // I should check `parse_type.dart` for array handling.

    // If `parseType` handles `[`, I need to pass `[` token.
  }

  final (type, suffix) = parseType(context, symbolgraph, suffixFragments);
  assert(suffix.isEmpty, '$suffix');
  return type;
}
