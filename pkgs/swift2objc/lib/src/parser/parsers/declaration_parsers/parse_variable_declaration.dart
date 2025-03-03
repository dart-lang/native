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
  final isConstant = _parseVariableIsConstant(propertySymbolJson);
  final variableModifiers = findKeywordsInFragments(propertySymbolJson);

  return PropertyDeclaration(
    id: parseSymbolId(propertySymbolJson),
    name: parseSymbolName(propertySymbolJson),
    type: _parseVariableType(propertySymbolJson, symbolgraph),
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(propertySymbolJson),
    isConstant: isConstant,
    hasSetter: isConstant ? false : _parsePropertyHasSetter(propertySymbolJson),
    isStatic: isStatic,
    throws: variableModifiers.throws,
    async: variableModifiers.async,
    unowned: variableModifiers.unowned,
    weak: variableModifiers.weak,
    lazy: variableModifiers.lazy,
  );
}

GlobalVariableDeclaration parseGlobalVariableDeclaration(
  Json variableSymbolJson,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final isConstant = _parseVariableIsConstant(variableSymbolJson);
  final hasSetter = _parsePropertyHasSetter(variableSymbolJson);
  final variableModifiers = findKeywordsInFragments(variableSymbolJson);

  return GlobalVariableDeclaration(
    id: parseSymbolId(variableSymbolJson),
    name: parseSymbolName(variableSymbolJson),
    type: _parseVariableType(variableSymbolJson, symbolgraph),
    isConstant: isConstant || !hasSetter,
    throws: variableModifiers.throws,
    async: variableModifiers.async
  );
}

ReferredType _parseVariableType(
  Json propertySymbolJson,
  ParsedSymbolgraph symbolgraph,
) =>
    parseTypeAfterSeparator(
        TokenList(propertySymbolJson['names']['subHeading']), symbolgraph);

bool _parseVariableIsConstant(Json variableSymbolJson) {
  final fragmentsJson = variableSymbolJson['declarationFragments'];

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
  final keywordIsPresent = json['declarationFragments']
      .any((frag) => matchFragment(frag, 'keyword', keyword));
  return keywordIsPresent;
}

class PropertyKeywords {
  bool async;
  bool throws;
  bool unowned;
  bool weak;
  bool lazy;

  PropertyKeywords({
    this.async = false,
    this.throws = false,
    this.unowned = false,
    this.weak = false,
    this.lazy = false,
  });
}

PropertyKeywords findKeywordsInFragments(Json json) {
  return PropertyKeywords(
    async: _findKeywordInFragments(json, 'async'),
    throws: _findKeywordInFragments(json, 'throws'),
    unowned: _findKeywordInFragments(json, 'unowned'),
    weak: _findKeywordInFragments(json, 'weak'),
    lazy: _findKeywordInFragments(json, 'lazy')
  );
}


bool _parsePropertyHasSetter(Json propertySymbolJson) {
  final fragmentsJson = propertySymbolJson['declarationFragments'];

  final hasExplicitSetter =
      fragmentsJson.any((frag) => matchFragment(frag, 'keyword', 'set'));
  final hasExplicitGetter =
      fragmentsJson.any((frag) => matchFragment(frag, 'keyword', 'get'));

  if (hasExplicitGetter) {
    if (hasExplicitSetter) {
      // has explicit getter and has explicit setter
      return true;
    } else {
      // has explicit getter and no explicit setter
      return false;
    }
  } else {
    if (hasExplicitSetter) {
      // has no explicit getter and but has explicit setter
      throw Exception(
        'Invalid property at ${propertySymbolJson.path}. '
        'Properties can not have a setter without a getter',
      );
    } else {
      // has no explicit getter and no explicit setter
      return true;
    }
  }
}
