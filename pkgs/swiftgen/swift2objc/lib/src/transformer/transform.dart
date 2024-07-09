// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/compound_declaration.dart';
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/_core/interfaces/enum_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/ast/declarations/globals/globals.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/transformers/transform_class.dart';

typedef TransformationMap = Map<Declaration, Declaration>;

List<Declaration> transform(List<Declaration> declarations) {
  final TransformationMap transformationMap = {};

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
      .toList();
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
