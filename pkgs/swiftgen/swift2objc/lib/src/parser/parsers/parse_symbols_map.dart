// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/parser/_core/json.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';

import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../_core/utils.dart';

ParsedSymbolsMap parseSymbolsMap(Json symbolgraphJson) {
  final parsedSymbols = {
    for (final decl in BuiltInDeclarations.declarations)
      decl.id: ParsedSymbol(json: Json(null), declaration: decl)
  };

  for (final symbolJson in symbolgraphJson["symbols"]) {
    final symbolId = parseSymbolId(symbolJson);
    parsedSymbols[symbolId] = ParsedSymbol(json: symbolJson);
  }

  return parsedSymbols;
}
