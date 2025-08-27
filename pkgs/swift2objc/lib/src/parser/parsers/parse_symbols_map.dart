// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../config.dart';
import '../_core/json.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/utils.dart';

ParsedSymbolsMap parseSymbolsMap(InputConfig source, Json symbolgraphJson) {
  final symbols = <String, ParsedSymbol>{};
  for (final symbolJson in symbolgraphJson['symbols']) {
    final id = parseSymbolId(symbolJson);
    final symbol = ParsedSymbol(source: source, json: symbolJson);
    // TODO: Fix and re-enable this check.
    // final old = symbols[id];
    // if (old != null && old.json.toString() != symbol.json.toString()) {
    //   throw SymbolIdCollisionError(old, symbol);
    // }
    symbols[id] = symbol;
  }
  return symbols;
}
