// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../context.dart';
import '../_core/json.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/token_list.dart';
import 'parse_declarations.dart';

/// Parse a type from a list of Json fragments.
///
/// Returns the parsed type, and a Json slice of the remaining fragments that
/// weren't part of the type.
(ReferredType, TokenList) parseType(
  Context context,
  ParsedSymbolgraph symbolgraph,
  TokenList fragments,
) {
  var (type, suffix) = _parsePrefixTypeExpression(
    context,
    symbolgraph,
    fragments,
  );
  while (true) {
    final (nextType, nextSuffix) = _maybeParseSuffixTypeExpression(
      context,
      symbolgraph,
      type,
      suffix,
    );
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
  Context context,
  ParsedSymbolgraph symbolgraph,
  TokenList fragments,
) {
  final token = fragments[0];
  final parselet = _prefixParsets[_tokenId(token)];
  if (parselet == null) {
    throw Exception('Invalid type at "${token.path}": $token');
  }
  return parselet(context, symbolgraph, token, fragments.slice(1));
}

// Suffix expressions are infix operators or suffix operators (basically
// anything that isn't a prefix). If we were parsing a programming language,
// these would be things like `x + y`, `z!`, or even `x ? y : z`.
(ReferredType?, TokenList) _maybeParseSuffixTypeExpression(
  Context context,
  ParsedSymbolgraph symbolgraph,
  ReferredType prefixType,
  TokenList fragments,
) {
  if (fragments.isEmpty) return (null, fragments);
  final token = fragments[0];
  final parselet = _suffixParsets[_tokenId(token)];
  if (parselet == null) return (null, fragments);
  return parselet(context, symbolgraph, prefixType, token, fragments.slice(1));
}

// For most tokens, we only care about the kind. But some tokens just have a
// kind of 'text', and the spelling is what distinguishes them.
String _tokenId(Json token) {
  final kind = token['kind'].get<String>();
  if (kind == 'text' || kind == 'keyword') {
    return '$kind: ${token['spelling'].get<String>()}';
  }
  return kind;
}

// ========================
// === Prefix parselets ===
// ========================

typedef PrefixParselet =
    (ReferredType, TokenList) Function(
      Context context,
      ParsedSymbolgraph symbolgraph,
      Json token,
      TokenList fragments,
    );

(ReferredType, TokenList) _typeIdentifierParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  Json token,
  TokenList fragments,
) {
  final preciseIdJson = token['preciseIdentifier'];
  if (!preciseIdJson.exists) {
    final spelling = token['spelling'].get<String>();
    if (spelling == 'Self') {
      return (selfType, fragments);
    }
    throw Exception(
      'Type at "${token.path}" has no preciseIdentifier '
      'and is not Self: $token',
    );
  }
  final id = preciseIdJson.get<String>();
  final symbol = symbolgraph.symbols[id];

  if (symbol == null) {
    throw Exception(
      'The type at "${token.path}" does not exist among parsed symbols: $token',
    );
  }

  final type = parseDeclaration(context, symbol, symbolgraph).asDeclaredType;
  return (type, fragments);
}

(ReferredType, TokenList) _tupleParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  Json token,
  TokenList fragments,
) {
  var currentFragments = fragments;
  final elements = <TupleElement>[];

  while (currentFragments.isNotEmpty &&
      _tokenId(currentFragments[0]) != 'text: )') {
    String? label;

    if (currentFragments.length > 1 &&
        _tokenId(currentFragments[1]) == 'text: :') {
      label = currentFragments[0]['spelling'].get<String>();
      currentFragments = currentFragments.slice(2);
    }

    final (elementType, nextFragments) = parseType(
      context,
      symbolgraph,
      currentFragments,
    );

    elements.add(TupleElement(label: label, type: elementType));
    currentFragments = nextFragments;

    if (currentFragments.isNotEmpty &&
        _tokenId(currentFragments[0]) == 'text: ,') {
      currentFragments = currentFragments.slice(1);
    }
  }

  if (currentFragments.isNotEmpty &&
      _tokenId(currentFragments[0]) == 'text: )') {
    currentFragments = currentFragments.slice(1);
  } else {
    throw Exception('Expected closing parenthesis for tuple at ${token.path}');
  }

  if (elements.isEmpty) {
    return (voidType, currentFragments);
  }

  if (elements.length == 1) {
    return (elements[0].type, currentFragments);
  }

  return (TupleType(elements), currentFragments);
}

(ReferredType, TokenList) _inoutParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  Json token,
  TokenList fragments,
) {
  if (_tokenId(fragments[0]) == 'text: ') {
    fragments = fragments.slice(1);
  }
  // TODO(https://github.com/dart-lang/native/issues/1754): Mark the returned
  // type as inout (maybe wrap it in a new InOutType AST node?).
  return parseType(context, symbolgraph, fragments);
}

Map<String, PrefixParselet> _prefixParsets = {
  'typeIdentifier': _typeIdentifierParselet,
  'text: (': _tupleParselet,
  'keyword: inout': _inoutParselet,
};

// ========================
// === Suffix parselets ===
// ========================

typedef SuffixParselet =
    (ReferredType, TokenList) Function(
      Context context,
      ParsedSymbolgraph symbolgraph,
      ReferredType prefixType,
      Json token,
      TokenList fragments,
    );

(ReferredType, TokenList) _optionalParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  ReferredType prefixType,
  Json token,
  TokenList fragments,
) => (OptionalType(prefixType), fragments);

(ReferredType, TokenList) _nestedTypeParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  ReferredType prefixType,
  Json token,
  TokenList fragments,
) {
  // Parsing Foo.Bar. Foo is in prefixType, and the token is ".". Bar's ID
  // is a globally uniquely identifier. We don't need to use Foo as a namespace.
  // So we can actually completely discard Foo and just parse Bar.
  return parseType(context, symbolgraph, fragments);
}

Map<String, SuffixParselet> _suffixParsets = {
  'text: ?': _optionalParselet,
  'text: .': _nestedTypeParselet,
};
