// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

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
  return symbolJson['names']['subHeading']
      .firstJsonWhereKey('kind', 'identifier')['spelling']
      .get();
}

bool symbolHasObjcAnnotation(Json symbolJson) {
  return symbolJson['declarationFragments']
      .jsonWithKeyExists('attribute', '@objc');
}
