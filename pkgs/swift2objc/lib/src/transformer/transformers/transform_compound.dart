// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/nestable_declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/compounds/struct_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_initializer.dart';
import 'transform_variable.dart';

ClassDeclaration transformCompound(
  CompoundDeclaration originalCompound,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  final isStub = state.stubs.contains(originalCompound);
  final compoundNamer = UniqueNamer.inCompound(originalCompound);

  final wrappedCompoundInstance = PropertyDeclaration(
    id: originalCompound.id.addIdSuffix('wrappedInstance'),
    name: compoundNamer.makeUnique('wrappedInstance'),
    source: originalCompound.source,
    availability: const [],
    type: originalCompound.asDeclaredType,
  );

  final transformedCompound = ClassDeclaration(
    id: originalCompound.id.addIdSuffix('wrapper'),
    name: parentNamer.makeUnique('${originalCompound.name}Wrapper'),
    source: originalCompound.source,
    availability: originalCompound.availability,
    hasObjCAnnotation: true,
    superClass: objectType,
    isWrapper: true,
    isStub: isStub,
    wrappedInstance: wrappedCompoundInstance,
    wrapperInitializer: buildWrapperInitializer(wrappedCompoundInstance),
  );

  state.map[originalCompound] = transformedCompound;

  transformedCompound.nestedDeclarations = originalCompound.nestedDeclarations
      .map(
        (nested) =>
            maybeTransformDeclaration(
                  nested,
                  compoundNamer,
                  state,
                  nested: true,
                )
                as InnerNestableDeclaration?,
      )
      .nonNulls
      .sortedById();
  transformedCompound.nestedDeclarations.fillNestingParents(
    transformedCompound,
  );

  if (!isStub) {
    final transformedProperties = originalCompound.properties
        .map(
          (property) => transformProperty(
            property,
            wrappedCompoundInstance,
            parentNamer,
            state,
          ),
        )
        .nonNulls
        .toList();

    final transformedInitializers = _compoundInitializers(originalCompound)
        .map(
          (initializer) => transformInitializer(
            initializer,
            wrappedCompoundInstance,
            parentNamer,
            state,
          ),
        )
        .toList();

    final transformedMethods = originalCompound.methods
        .map(
          (method) => transformMethod(
            method,
            wrappedCompoundInstance,
            parentNamer,
            state,
          ),
        )
        .nonNulls
        .toList();

    transformedCompound.properties = transformedProperties
        .removeWhereType<PropertyDeclaration>()
        .sortedById();

    transformedCompound.initializers = transformedInitializers
        .removeWhereType<InitializerDeclaration>()
        .sortedById();

    transformedCompound.methods = [
      ...transformedMethods,
      ...transformedProperties.removeWhereType<MethodDeclaration>(),
      ...transformedInitializers.removeWhereType<MethodDeclaration>(),
    ].sortedById();

    assert(transformedProperties.isEmpty);
    assert(transformedInitializers.isEmpty);
  }

  return transformedCompound;
}

List<InitializerDeclaration> _compoundInitializers(
  CompoundDeclaration originalCompound,
) {
  final initializers = originalCompound.initializers;
  if (originalCompound is! StructDeclaration || initializers.isNotEmpty) {
    return initializers;
  }
  final storedProperties = originalCompound.properties
      .where((prop) => !prop.isStatic && !prop.hasExplicitGetter)
      .sortedById();

  if (storedProperties.isEmpty) {
    return initializers;
  }

  final implicitInit = InitializerDeclaration(
    id: originalCompound.id.addIdSuffix('implicit_init'),
    source: originalCompound.source,
    availability: originalCompound.availability,
    params: storedProperties
        .map(
          (prop) =>
              Parameter(name: prop.name, internalName: null, type: prop.type),
        )
        .toList(),
    hasObjCAnnotation: true,
    isOverriding: false,
    throws: false,
    async: false,
    isFailable: false,
  );

  return [implicitInit];
}
