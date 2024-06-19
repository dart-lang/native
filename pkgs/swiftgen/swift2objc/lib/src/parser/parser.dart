// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/enum_declaration.dart';
import 'package:swift2objc/src/ast/ast.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/struct_declaration.dart';
import 'package:swift2objc/src/ast/declarations/globals/globals.dart';
import 'package:swift2objc/src/parser/_core/parsed_symbolgraph.dart';

import '_core/utils.dart';
import 'parsers/parse_declarations.dart';
import 'parsers/parse_realtions_map.dart';
import 'parsers/parse_symbols_map.dart';

Ast parseAst(String symbolgraphJsonPath) {
  final symbolgraphJson = readJsonFile(symbolgraphJsonPath);

  final symbolgraph = ParsedSymbolgraph(
    parseSymbolsMap(symbolgraphJson),
    parseRelationsMap(symbolgraphJson),
  );

  final declarations = parseDeclarations(symbolgraph);

  return Ast(
    classes: declarations.whereType<ClassDeclaration>().toList(),
    structs: declarations.whereType<StructDeclaration>().toList(),
    enums: declarations.whereType<EnumDeclaration>().toList(),
    globals: Globals(
      functions: declarations.whereType<GlobalFunctionDeclaration>().toList(),
      values: declarations.whereType<GlobalValueDeclaration>().toList(),
    ),
  );
}
