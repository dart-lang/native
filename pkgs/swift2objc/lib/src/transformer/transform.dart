// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast/_core/interfaces/compound_declaration.dart';
import '../ast/_core/interfaces/declaration.dart';
import '../ast/_core/interfaces/nestable_declaration.dart';
import '../ast/declarations/built_in/built_in_declaration.dart';
import '../ast/declarations/compounds/class_declaration.dart';
import '../ast/declarations/compounds/enum_declaration.dart';
import '../ast/declarations/compounds/struct_declaration.dart';
import '../ast/declarations/globals/globals.dart';
import '../ast/declarations/typealias_declaration.dart';
import '../ast/visitor.dart';
import '../context.dart';
import '../parser/_core/utils.dart';
import '_core/dependencies.dart';
import '_core/unique_namer.dart';
import '_core/utils.dart';
import 'transformers/transform_compound.dart';
import 'transformers/transform_enum.dart';
import 'transformers/transform_globals.dart';

class TransformationState {
  // Map from untransformed decleration to its transformed declaration, or null
  // if there is generated code for the declaration.
  final map = <Declaration, Declaration?>{};

  // All the bindings to be generated.
  final bindings = <Declaration>{};

  // Bindings that will be generated as stubs.
  final stubs = <Declaration>{};

  // Map from tuple signature to generated wrapper class
  final _tupleWrappers = <String, ClassDeclaration>{};

  /// Check if a tuple wrapper class has already been generated
  bool hasGeneratedTuple(String className) =>
      _tupleWrappers.containsKey(className);

  /// Get the wrapper class for a tuple
  ClassDeclaration getTupleWrapper(String className) =>
      _tupleWrappers[className]!;

  /// Register a newly generated tuple wrapper class
  void registerTupleWrapper(String className, ClassDeclaration wrapperClass) {
    _tupleWrappers[className] = wrapperClass;
    bindings.add(wrapperClass);
  }

  /// Get all generated tuple wrapper classes
  List<ClassDeclaration> get tupleWrappers => _tupleWrappers.values.toList();
}

/// Transforms the given declarations into the desired ObjC wrapped declarations
List<Declaration> transform(
  Context context,
  List<Declaration> declarations, {
  required bool Function(Declaration) filter,
}) {
  final state = TransformationState();

  final includes = visit(
    context,
    FindIncludesVisitation(filter),
    declarations,
  ).includes;
  final directTransitives = visit(
    context,
    FindDirectTransitiveDepsVisitation(includes),
    includes,
  ).directTransitives;
  state.bindings.addAll(includes.union(directTransitives));
  final listDecls = visit(
    context,
    ListDeclsVisitation(includes, directTransitives),
    state.bindings,
  );
  final topLevelDecls = listDecls.topLevelDecls.toList();
  state.stubs.addAll(listDecls.stubDecls);
  state.bindings.addAll(listDecls.stubDecls);

  final globalNamer = UniqueNamer(
    state.bindings.map((declaration) => declaration.name),
  );

  final globals = Globals(
    functions: topLevelDecls.removeWhereType<GlobalFunctionDeclaration>(),
    variables: topLevelDecls.removeWhereType<GlobalVariableDeclaration>(),
  );

  final transformedDeclarations = [
    ...topLevelDecls.map(
      (d) => maybeTransformDeclaration(d, globalNamer, state),
    ),
    transformGlobals(globals, globalNamer, state),
  ].nonNulls.toList();

  return [
    ...transformedDeclarations,
    ..._getPrimitiveWrapperClasses(state),
    ...state.tupleWrappers,
  ].sortedById();
}

Declaration transformDeclaration(
  Declaration declaration,
  UniqueNamer parentNamer,
  TransformationState state, {
  bool nested = false,
}) =>
    maybeTransformDeclaration(
      declaration,
      parentNamer,
      state,
      nested: nested,
    ) ??
    declaration;

Declaration? maybeTransformDeclaration(
  Declaration declaration,
  UniqueNamer parentNamer,
  TransformationState state, {
  bool nested = false,
}) {
  if (!state.bindings.contains(declaration)) {
    return null;
  }

  if (state.map.containsKey(declaration)) {
    return state.map[declaration];
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
      state,
    ),
    EnumDeclaration() => transformEnum(declaration, parentNamer, state),
    TypealiasDeclaration() => null,
    _ => throw UnimplementedError(),
  };
}

List<Declaration> _getPrimitiveWrapperClasses(TransformationState state) =>
    state.map.entries
        .where((entry) => entry.key is BuiltInDeclaration)
        .map((entry) => entry.value)
        .nonNulls
        .toList();
