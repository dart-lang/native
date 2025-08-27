// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';
import '_core/json.dart';
import '_core/parsed_symbolgraph.dart';
import 'parsers/parse_relations_map.dart';
import 'parsers/parse_symbols_map.dart';

export '_core/parsed_symbolgraph.dart';
export '_core/utils.dart';
export 'parsers/parse_declarations.dart';

ParsedSymbolgraph parseSymbolgraph(InputConfig source, Json symbolgraphJson) =>
    ParsedSymbolgraph(
      symbols: parseSymbolsMap(source, symbolgraphJson),
      relations: parseRelationsMap(source, symbolgraphJson),
    );

String? parseModuleName(Json symbolgraphJson) =>
    symbolgraphJson['module']['name'].get();
