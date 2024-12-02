// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/compound_declaration.dart';
import '../ast/_core/interfaces/declaration.dart';
import '../ast/_core/interfaces/nestable_declaration.dart';
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
  final transformationMap = <Declaration, Declaration>{};

  final _declarations = declarations.where(filter ?? (declaration) => true);

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
  UniqueNamer parentNamer,
  TransformationMap transformationMap, {
  bool nested = false,
}) {
  if (transformationMap[declaration] != null) {
    return transformationMap[declaration]!;
  }

  if (declaration is NestableDeclaration && declaration.nestingParent != null) {
    // It's important that nested declarations are only transformed in the
    // context of their parent, so that their parentNamer is correct.
    assert(nested);
  }

  return switch (declaration) {
    ClassDeclaration() || StructDeclaration() => transformCompound(
        declaration as CompoundDeclaration,
        parentNamer,
        transformationMap,
      ),
    _ => throw UnimplementedError(),
  };
}
