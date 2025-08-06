// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/compound_declaration.dart';
import '../ast/_core/interfaces/declaration.dart';
import '../ast/_core/interfaces/nestable_declaration.dart';
import '../ast/declarations/built_in/built_in_declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import '../ast/declarations/compounds/struct_declaration.dart';
import '../ast/declarations/globals/globals.dart';
import '../ast/declarations/typealias_declaration.dart';
import '../ast/visitor.dart';
import '_core/dependencies.dart';
import '_core/unique_namer.dart';
import 'transformers/transform_compound.dart';
import 'transformers/transform_globals.dart';

typedef TransformationMap = Map<Declaration, Declaration?>;

Set<Declaration> generateDependencies(Iterable<Declaration> decls) =>
    visit(DependencyVisitation(), decls).topLevelDeclarations;

/// Transforms the given declarations into the desired ObjC wrapped declarations
List<Declaration> transform(List<Declaration> declarations,
    {required bool Function(Declaration) filter}) {
  final transformationMap = <Declaration, Declaration?>{};

  final declarations0 = declarations.where(filter).toSet();
  declarations0.addAll(generateDependencies(declarations0));

  final globalNamer = UniqueNamer(
    declarations0.map((declaration) => declaration.name),
  );

  final globals = Globals(
    functions: declarations0.whereType<GlobalFunctionDeclaration>().toList(),
    variables: declarations0.whereType<GlobalVariableDeclaration>().toList(),
  );
  final nonGlobals = declarations0
      .where(
        (declaration) =>
            declaration is! GlobalFunctionDeclaration &&
            declaration is! GlobalVariableDeclaration,
      )
      .toList();

  final transformedDeclarations = [
    ...nonGlobals
        .map(
          (d) => maybeTransformDeclaration(d, globalNamer, transformationMap),
        )
        .nonNulls,
    if (globals.functions.isNotEmpty || globals.variables.isNotEmpty)
      transformGlobals(globals, globalNamer, transformationMap),
  ];

  return (transformedDeclarations +
      _getPrimitiveWrapperClasses(transformationMap))
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));
}

Declaration transformDeclaration(
  Declaration declaration,
  UniqueNamer parentNamer,
  TransformationMap transformationMap, {
  bool nested = false,
}) =>
    maybeTransformDeclaration(declaration, parentNamer, transformationMap,
        nested: nested) ??
    declaration;

Declaration? maybeTransformDeclaration(
  Declaration declaration,
  UniqueNamer parentNamer,
  TransformationMap transformationMap, {
  bool nested = false,
}) {
  if (transformationMap.containsKey(declaration)) {
    return transformationMap[declaration];
  }

  if (declaration is InnerNestableDeclaration &&
      declaration.nestingParent != null) {
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
    TypealiasDeclaration() => null,
    _ => throw UnimplementedError(),
  };
}

List<Declaration> _getPrimitiveWrapperClasses(
    TransformationMap transformationMap) {
  return transformationMap.entries
      .where((entry) => entry.key is BuiltInDeclaration)
      .map((entry) => entry.value)
      .nonNulls
      .toList();
}
