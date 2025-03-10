// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/property_declaration.dart';
import '../../../ast/declarations/globals/globals.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';

PropertyDeclaration parsePropertyDeclaration(
  Json propertySymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final info = parsePropertyInfo(propertySymbolJson['declarationFragments']);
  return PropertyDeclaration(
    id: parseSymbolId(propertySymbolJson),
    name: parseSymbolName(propertySymbolJson),
    type: _parseVariableType(propertySymbolJson, symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(propertySymbolJson),
    isConstant: info.constant,
    hasSetter: info.constant ? false : info.setter,
    isStatic: isStatic,
    throws: info.throws,
    async: info.async,
  );
}

GlobalVariableDeclaration parseGlobalVariableDeclaration(
  Json variableSymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final info = parsePropertyInfo(variableSymbolJson['declarationFragments']);
  return GlobalVariableDeclaration(
    id: parseSymbolId(variableSymbolJson),
    name: parseSymbolName(variableSymbolJson),
    type: _parseVariableType(variableSymbolJson, symbolgraph),
    isConstant: info.constant || !info.setter,
    throws: info.throws,
    async: info.async,
  );
}

ReferredType _parseVariableType(
  Json propertySymbolJson,
  ParsedSymbolgraph symbolgraph,
) =>
    parseTypeAfterSeparator(
        TokenList(propertySymbolJson['names']['subHeading']), symbolgraph);

bool _parseVariableIsConstant(Json fragmentsJson) {
  final declarationKeyword = fragmentsJson.firstWhere(
    (json) =>
        matchFragment(json, 'keyword', 'var') ||
        matchFragment(json, 'keyword', 'let'),
    orElse: () => throw ArgumentError(
      'Invalid property declaration fragments at path: ${fragmentsJson.path}. '
      'Expected to find "var" or "let" as a keyword, found none',
    ),
  );
  return matchFragment(declarationKeyword, 'keyword', 'let');
}

bool _findKeywordInFragments(Json json, String keyword) {
  final keywordIsPresent =
      json.any((frag) => matchFragment(frag, 'keyword', keyword));
  return keywordIsPresent;
}

typedef ParsedPropertyInfo = ({
  bool async,
  bool throws,
  bool constant,
  bool getter,
  bool setter,
  bool mutating,
});

ParsedPropertyInfo parsePropertyInfo(Json json) {
  final (getter, setter) = _parsePropertyGetandSet(json);
  return (
    constant: _parseVariableIsConstant(json),
    async: _findKeywordInFragments(json, 'async'),
    throws: _findKeywordInFragments(json, 'throws'),
    getter: getter,
    setter: setter,
    mutating: _findKeywordInFragments(json, 'mutating')
  );
}

(bool, bool) _parsePropertyGetandSet(Json fragmentsJson, {String? path}) {
  if (fragmentsJson.any((frag) => matchFragment(frag, 'text', ' { get }'))) {
    // has explicit getter and no explicit setter
    return (true, false);
  }

  final hasExplicitSetter =
      fragmentsJson.any((frag) => matchFragment(frag, 'keyword', 'set'));
  final hasExplicitGetter =
      fragmentsJson.any((frag) => matchFragment(frag, 'keyword', 'get'));

  if (hasExplicitGetter) {
    if (hasExplicitSetter) {
      // has explicit getter and has explicit setter
      return (true, true);
    } else {
      // has explicit getter and no explicit setter
      return (true, false);
    }
  } else {
    if (hasExplicitSetter) {
      // has no explicit getter and but has explicit setter
      throw Exception(
        'Invalid property${path != null ? ' at $path' : ''}. '
        'Properties can not have a setter without a getter',
      );
    } else {
      // has no explicit getter and no explicit setter
      return (false, false);
    }
  }
}
