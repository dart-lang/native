// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/enum_declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/globals/globals.dart';
import '../parsers/parse_declarations.dart';
import 'json.dart';
import 'parsed_symbolgraph.dart';

typedef ParsedSymbolsMap = Map<String, ParsedSymbol>;
typedef ParsedRelationsMap = Map<String, List<ParsedRelation>>;

Json readJsonFile(String jsonFilePath) {
  final jsonStr = File(jsonFilePath).readAsStringSync();
  return Json(jsonDecode(jsonStr));
}

const idDelim = '-';

extension AddIdSuffix on String {
  String addIdSuffix(String suffix) => '$this$idDelim$suffix';
}

extension TopLevelOnly<T extends Declaration> on List<T> {
  List<Declaration> get topLevelOnly => where(
        (declaration) =>
            declaration is CompoundDeclaration ||
            declaration is EnumDeclaration ||
            declaration is GlobalVariableDeclaration ||
            declaration is GlobalFunctionDeclaration,
      ).toList();
}

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
  return symbolJson['declarationFragments'].any(
    (json) =>
        json['kind'].exists &&
        json['kind'].get<String>() == 'attribute' &&
        json['spelling'].exists &&
        json['spelling'].get<String>() == '@objc',
  );
}

bool parseIsOverriding(Json symbolJson) {
  return symbolJson['declarationFragments'].any(
    (json) =>
        json['kind'].exists &&
        json['kind'].get<String>() == 'keyword' &&
        json['spelling'].exists &&
        json['spelling'].get<String>() == 'override',
  );
}

ReferredType parseTypeFromId(String typeId, ParsedSymbolgraph symbolgraph) {
  final paramTypeSymbol = symbolgraph.symbols[typeId];

  if (paramTypeSymbol == null) {
    throw Exception(
      'Type with id "$typeId" does not exist among parsed symbols.',
    );
  }

  final paramTypeDeclaration = parseDeclaration(paramTypeSymbol, symbolgraph);

  return paramTypeDeclaration.asDeclaredType;
}
