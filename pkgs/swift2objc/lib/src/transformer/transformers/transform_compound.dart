// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/nestable_declaration.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
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
  TransformationMap transformationMap,
) {
  final compoundNamer = UniqueNamer.inCompound(originalCompound);

  final wrappedCompoundInstance = PropertyDeclaration(
    id: originalCompound.id.addIdSuffix('wrappedInstance'),
    name: compoundNamer.makeUnique('wrappedInstance'),
    type: originalCompound.asDeclaredType,
  );

  final transformedCompound = ClassDeclaration(
    id: originalCompound.id.addIdSuffix('wrapper'),
    name: parentNamer.makeUnique('${originalCompound.name}Wrapper'),
    hasObjCAnnotation: true,
    superClass: objectType,
    isWrapper: true,
    wrappedInstance: wrappedCompoundInstance,
    wrapperInitializer: buildWrapperInitializer(wrappedCompoundInstance),
  );

  transformationMap[originalCompound] = transformedCompound;

  transformedCompound.nestedDeclarations = originalCompound.nestedDeclarations
      .map((nested) => transformDeclaration(
              nested, compoundNamer, transformationMap, nested: true)
          as NestableDeclaration)
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));
  transformedCompound.nestedDeclarations
      .fillNestingParents(transformedCompound);

  final transformedProperties = originalCompound.properties
      .map((property) => transformProperty(
            property,
            wrappedCompoundInstance,
            parentNamer,
            transformationMap,
          ))
      .nonNulls
      .toList();

  final transformedInitializers = originalCompound.initializers
      .map((initializer) => transformInitializer(
            initializer,
            wrappedCompoundInstance,
            parentNamer,
            transformationMap,
          ))
      .toList();

  final transformedMethods = originalCompound.methods
      .map((method) => transformMethod(
            method,
            wrappedCompoundInstance,
            parentNamer,
            transformationMap,
          ))
      .nonNulls
      .toList();

  transformedCompound.properties = transformedProperties
      .whereType<PropertyDeclaration>()
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedCompound.initializers = transformedInitializers
      .whereType<InitializerDeclaration>()
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedCompound.methods = (transformedMethods +
      transformedProperties.whereType<MethodDeclaration>().toList() +
      transformedInitializers.whereType<MethodDeclaration>().toList())
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedCompound;
}
