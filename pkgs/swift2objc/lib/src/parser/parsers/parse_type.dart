// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../_core/json.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/token_list.dart';
import 'parse_declarations.dart';

/// Parse a type from a list of Json fragments.
///
/// Returns the parsed type, and a Json slice of the remaining fragments that
/// weren't part of the type.
(ReferredType, TokenList) parseType(
    ParsedSymbolgraph symbolgraph, TokenList fragments) {
  var (type, suffix) = _parsePrefixTypeExpression(symbolgraph, fragments);
  while (true) {
    final (nextType, nextSuffix) =
        _maybeParseSuffixTypeExpression(symbolgraph, type, suffix);
    if (nextType == null) break;
    type = nextType;
    suffix = nextSuffix;
  }
  return (type, suffix);
}

// Prefix expressions are literals or prefix operators (stuff that can appear
// at the beginning of the list of fragments). If we were parsing a programming
// language, these would be things like `123` or `-x`.
(ReferredType, TokenList) _parsePrefixTypeExpression(
    ParsedSymbolgraph symbolgraph, TokenList fragments) {
  final token = fragments[0];
  final parselet = _prefixParsets[_tokenId(token)];
  if (parselet == null) throw Exception('Invalid type at "${token.path}"');
  return parselet(symbolgraph, token, fragments.slice(1));
}

// Suffix expressions are infix operators or suffix operators (basically
// anything that isn't a prefix). If we were parsing a programming language,
// these would be things like `x + y`, `z!`, or even `x ? y : z`.
(ReferredType?, TokenList) _maybeParseSuffixTypeExpression(
    ParsedSymbolgraph symbolgraph,
    ReferredType prefixType,
    TokenList fragments) {
  if (fragments.isEmpty) return (null, fragments);
  final token = fragments[0];
  final parselet = _suffixParsets[_tokenId(token)];
  if (parselet == null) return (null, fragments);
  return parselet(symbolgraph, prefixType, token, fragments.slice(1));
}

// For most tokens, we only care about the kind. But some tokens just have a
// kind of 'text', and the spelling is what distinguishes them.
String _tokenId(Json token) {
  final kind = token['kind'].get<String>();
  return kind == 'text' ? 'text: ${token['spelling'].get<String>()}' : kind;
}

// ========================
// === Prefix parselets ===
// ========================

typedef PrefixParselet = (ReferredType, TokenList) Function(
    ParsedSymbolgraph symbolgraph, Json token, TokenList fragments);

(ReferredType, TokenList) _typeIdentifierParselet(
    ParsedSymbolgraph symbolgraph, Json token, TokenList fragments) {
  final id = token['preciseIdentifier'].get<String>();
  final symbol = symbolgraph.symbols[id];

  if (symbol == null) {
    throw Exception(
        'The type at "${token.path}" does not exist among parsed symbols.');
  }

  final type = parseDeclaration(symbol, symbolgraph).asDeclaredType;
  return (type, fragments);
}

(ReferredType, TokenList) _emptyTupleParselet(
        ParsedSymbolgraph symbolgraph, Json token, TokenList fragments) =>
    (voidType, fragments);

Map<String, PrefixParselet> _prefixParsets = {
  'typeIdentifier': _typeIdentifierParselet,
  'text: ()': _emptyTupleParselet,
};

// ========================
// === Suffix parselets ===
// ========================

typedef SuffixParselet = (ReferredType, TokenList) Function(
    ParsedSymbolgraph symbolgraph,
    ReferredType prefixType,
    Json token,
    TokenList fragments);

(ReferredType, TokenList) _optionalParselet(ParsedSymbolgraph symbolgraph,
        ReferredType prefixType, Json token, TokenList fragments) =>
    (OptionalType(prefixType), fragments);

Map<String, SuffixParselet> _suffixParsets = {
  'text: ?': _optionalParselet,
};
