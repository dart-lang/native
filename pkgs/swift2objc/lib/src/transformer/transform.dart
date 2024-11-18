// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/compound_declaration.dart';
import '../ast/_core/interfaces/declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import '../ast/declarations/compounds/struct_declaration.dart';
import '../ast/declarations/globals/globals.dart';
import '_core/unique_namer.dart';
import 'transformers/transform_compound.dart';
import 'transformers/transform_globals.dart';

typedef TransformationMap = Map<Declaration, Declaration>;

/// Transforms the given declarations into the desired ObjC wrapped declarations
List<Declaration> transform(List<Declaration> declarations, {
  bool Function(Declaration)? filter
}) {
  final TransformationMap transformationMap;
  final _filter = filter ?? (declaration) => true;

  final _declarations = declarations.where((d) => _filter(d));

  transformationMap = {};

  final globalNamer = UniqueNamer(
    _declarations.map((declaration) => declaration.name),
  );

  final globals = Globals(
    functions: _declarations.whereType<GlobalFunctionDeclaration>().toList(),
    variables: _declarations.whereType<GlobalVariableDeclaration>().toList(),
  );
  final nonGlobals = _declarations
      .where(
        (declaration) =>
            declaration is! GlobalFunctionDeclaration &&
            declaration is! GlobalVariableDeclaration,
      )
      .toList();

  final transformedDeclarations = [
    ...nonGlobals.map(
      (decl) => transformDeclaration(decl, globalNamer, transformationMap),
    ),
    if (globals.functions.isNotEmpty || globals.variables.isNotEmpty)
      transformGlobals(globals, globalNamer, transformationMap),
  ];

  return transformedDeclarations
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));
}

Declaration transformDeclaration(
  Declaration declaration,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (transformationMap[declaration] != null) {
    return transformationMap[declaration]!;
  }

  return switch (declaration) {
    ClassDeclaration() || StructDeclaration() => transformCompound(
        declaration as CompoundDeclaration,
        globalNamer,
        transformationMap,
      ),
    _ => throw UnimplementedError(),
  };
}
