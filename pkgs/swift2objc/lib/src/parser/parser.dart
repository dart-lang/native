// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/declaration.dart';
import '_core/json.dart';
import '_core/parsed_symbolgraph.dart';

import 'parsers/parse_declarations.dart';
import 'parsers/parse_relations_map.dart';
import 'parsers/parse_symbols_map.dart';

List<Declaration> parseAst(Json symbolgraphJson) {
  final symbolgraph = ParsedSymbolgraph(
    parseSymbolsMap(symbolgraphJson),
    parseRelationsMap(symbolgraphJson),
  );

  return parseDeclarations(symbolgraph);
}

String? parseModuleName(Json symbolgraphJson) =>
    symbolgraphJson['module']['name'].get();
