// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/compound_declaration.dart';
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/_core/interfaces/enum_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/transformer/transformers/transform_class.dart';

typedef TransformationMap = Map<Declaration, Declaration>;

List<Declaration> transform(List<Declaration> declarations) {
  final TransformationMap transformationMap = {};

  return declarations
      .where(
        (declaration) =>
            declaration is CompoundDeclaration ||
            declaration is EnumDeclaration,
      )
      .map((decl) => transformDeclaration(decl, transformationMap))
      .toList();
}

Declaration transformDeclaration(
  Declaration declaration,
  TransformationMap transformationMap,
) {
  if (transformationMap[declaration] != null) {
    return transformationMap[declaration]!;
  }

  return switch (declaration) {
    ClassDeclaration() => transformClass(declaration, transformationMap),
    _ => throw UnimplementedError(),
  };
}
