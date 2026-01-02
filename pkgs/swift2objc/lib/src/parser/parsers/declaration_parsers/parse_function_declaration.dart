// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/globals/globals.dart';
import '../../../context.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

GlobalFunctionDeclaration parseGlobalFunctionDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
  final info = parseFunctionInfo(
    context,
    symbol.json['declarationFragments'],
    symbolgraph,
  );
  return GlobalFunctionDeclaration(
    id: parseSymbolId(symbol.json),
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    returnType: _parseFunctionReturnType(context, symbol.json, symbolgraph),
    params: info.params,
    throws: info.throws,
    async: info.async,
  );
}

MethodDeclaration parseMethodDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final info = parseFunctionInfo(
    context,
    symbol.json['declarationFragments'],
    symbolgraph,
  );
  return MethodDeclaration(
    id: parseSymbolId(symbol.json),
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    returnType: _parseFunctionReturnType(context, symbol.json, symbolgraph),
    params: info.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(symbol.json),
    isStatic: isStatic,
    throws: info.throws,
    async: info.async,
    mutating: info.mutating,
  );
}

typedef ParsedFunctionInfo = ({
  List<Parameter> params,
  bool throws,
  bool async,
  bool mutating,
});

ParsedFunctionInfo parseFunctionInfo(
  Context context,
  Json declarationFragments,
  ParsedSymbolgraph symbolgraph,
) {
  // `declarationFragments` describes each part of the function declaration,
  // things like the `func` keyword, brackets, spaces, etc.
  // For the most part, We only care about the parameter fragments and
  // annotations here, and they always appear in this order:
  // [
  //   ..., '(',
  //   externalParam, ' ', internalParam, ': ', type..., ', '
  //   externalParam, ': ', type..., ', '
  //   externalParam, ' ', internalParam, ': ', type..., ')'
  //   annotations..., '->', returnType...
  // ]
  // Note: `internalParam` may or may not exist.
  //
  // The following loop attempts to extract parameters from this flat array
  // while making sure the parameter fragments have the expected order.

  final parameters = <Parameter>[];
  final malformedInitializerException = Exception(
    'Malformed parameter list at ${declarationFragments.path}: '
    '$declarationFragments',
  );

  var tokens = TokenList(declarationFragments);

  String? maybeConsume(String kind) {
    if (tokens.isEmpty) return null;
    final spelling = getSpellingForKind(tokens[0], kind);
    if (spelling != null) tokens = tokens.slice(1);
    return spelling;
  }

  final prefixAnnotations = <String>{};

  while (true) {
    final keyword = maybeConsume('keyword');
    if (keyword != null) {
      if (keyword == 'func' || keyword == 'init') {
        break;
      } else {
        prefixAnnotations.add(keyword);
      }
    } else {
      if (maybeConsume('text') != '') {
        throw malformedInitializerException;
      }
    }
  }

  final openParen = tokens.indexWhere((tok) => matchFragment(tok, 'text', '('));
  if (openParen == -1) throw malformedInitializerException;

  tokens = tokens.slice(openParen + 1);

  // Parse parameters until we find a ')'.
  if (maybeConsume('text') == ')') {
    // Empty param list.
  } else {
    while (true) {
      final externalParam = maybeConsume('externalParam');
      if (externalParam == null) throw malformedInitializerException;

      var sep = maybeConsume('text');
      String? internalParam;
      if (sep == '') {
        internalParam = maybeConsume('internalParam');
        if (internalParam == null) throw malformedInitializerException;
        sep = maybeConsume('text');
      }

      if (sep != ':') throw malformedInitializerException;
      final (type, remainingTokens) = parseType(context, symbolgraph, tokens);
      tokens = remainingTokens;

      // Optional: parse a default argument if present.
      // Swift symbol graph can emit defaults in these formats:
      // 1. Separate tokens: [": ", type..., " = ", value, ", "]
      // 2. Combined: [":", type..., " = value, "] or
      //    [":", type..., " = value)"]
      // 3. With return: [":", type..., " = value) -> "]
      //
      // We carefully preserve string literals during parsing to avoid
      // splitting on delimiters that appear inside quoted strings
      // (e.g., the ") -> " in the string literal "World ) -> ").
      String? defaultValue;
      String? endToken;
      var afterType = maybeConsume('text');

      if (afterType != null) {
        // Check if this text token contains '='
        var remaining = afterType.trim();
        if (remaining.startsWith('=')) {
          // Extract default value from this token
          remaining = remaining.substring(1).trim();

          // Check for delimiters: ',' or ')' (possibly followed by ' ->')
          if (remaining.contains(')')) {
            final parenIndex = remaining.indexOf(')');
            defaultValue = remaining.substring(0, parenIndex).trim();
            endToken = ')';
          } else if (remaining.contains(',')) {
            final commaIndex = remaining.indexOf(',');
            defaultValue = remaining.substring(0, commaIndex).trim();
            endToken = ',';
          } else if (remaining.isNotEmpty) {
            // Default value but no delimiter yet
            defaultValue = remaining;
            endToken = maybeConsume('text');
          } else {
            // '=' alone, collect tokens until delimiter
            final parts = <String>[];
            while (tokens.isNotEmpty) {
              final tok = tokens[0];
              final kind = tok['kind'].get<String?>();
              final spelling = tok['spelling'].get<String?>();
              if (spelling != null) {
                final s = spelling.trim();
                // String tokens should be kept whole, not split on delimiters
                if (kind == 'string') {
                  parts.add(spelling);
                  tokens = tokens.slice(1);
                } else if (s == ',' || s == ')') {
                  endToken = s;
                  tokens = tokens.slice(1);
                  break;
                } else if (s.contains(',') || s.contains(')')) {
                  final delimChar = s.contains(',') ? ',' : ')';
                  final delimIndex = s.indexOf(delimChar);
                  parts.add(s.substring(0, delimIndex).trim());
                  endToken = delimChar;
                  tokens = tokens.slice(1);
                  break;
                } else {
                  parts.add(spelling);
                  tokens = tokens.slice(1);
                }
              } else {
                tokens = tokens.slice(1);
              }
            }
            if (parts.isNotEmpty) {
              defaultValue = parts.join('').trim();
            }
          }
        } else {
          endToken = afterType;
        }
      }

      parameters.add(
        Parameter(
          name: externalParam,
          internalName: internalParam,
          type: type,
          defaultValue: defaultValue,
        ),
      );

      final end = endToken ?? maybeConsume('text');
      if (end == ')') break;
      if (end != ',') throw malformedInitializerException;
    }
  }

  // Parse annotations until we run out. The annotations are keywords separated
  // by whitespace tokens.
  final annotations = <String>{};
  while (true) {
    final keyword = maybeConsume('keyword');
    if (keyword == null) {
      if (maybeConsume('text') != '') break;
    } else {
      annotations.add(keyword);
    }
  }

  return (
    params: parameters,
    throws: annotations.contains('throws'),
    async: annotations.contains('async'),
    mutating: prefixAnnotations.contains('mutating'),
  );
}

ReferredType _parseFunctionReturnType(
  Context context,
  Json symbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final returnJson = TokenList(symbolJson['functionSignature']['returns']);
  final (returnType, unparsed) = parseType(context, symbolgraph, returnJson);
  assert(unparsed.isEmpty, '$returnJson\n\n$returnType\n\n$unparsed\n');
  return returnType;
}
