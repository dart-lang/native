// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/compound_declaration.dart';
import '../ast/_core/interfaces/declaration.dart';
import '../ast/_core/interfaces/enum_declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import '../ast/declarations/globals/globals.dart';
import '_core/unique_namer.dart';
import 'transformers/transform_class.dart';

typedef TransformationMap = Map<Declaration, Declaration>;

List<Declaration> transform(List<Declaration> declarations) {
  final TransformationMap transformationMap;

  transformationMap = {};

  final globalNamer = UniqueNamer({
    ...declarations
        .where(
          (declaration) =>
              declaration is CompoundDeclaration ||
              declaration is EnumDeclaration ||
              declaration is GlobalValueDeclaration ||
              declaration is GlobalFunctionDeclaration,
        )
        .map((declaration) => declaration.name)
  });

  return declarations
      .where(
        (declaration) =>
            declaration is CompoundDeclaration ||
            declaration is EnumDeclaration,
      )
      .map((decl) => transformDeclaration(decl, globalNamer, transformationMap))
      .toList()..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));
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
    ClassDeclaration() => transformClass(
        declaration,
        globalNamer,
        transformationMap,
      ),
    _ => throw UnimplementedError(),
  };
}
