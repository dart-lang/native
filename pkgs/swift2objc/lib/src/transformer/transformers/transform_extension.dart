// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/extension_declaration.dart';
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

ExtensionDeclaration? transformExtension(
  ExtensionDeclaration extDecl,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  // Find the already-transformed wrapper class for the extended type
  final transformedTarget = state.map[extDecl.extendedType.declaration];

  if (transformedTarget is! ClassDeclaration) return null;

  final wrappedInstance = transformedTarget.wrappedInstance;
  if (wrappedInstance == null) return null;

  final transformedMethods = extDecl.methods
      .map((m) => transformMethod(m, wrappedInstance, parentNamer, state))
      .nonNulls
      .toList();

  final transformedProperties = extDecl.properties
      .map((p) => transformProperty(p, wrappedInstance, parentNamer, state))
      .nonNulls
      .toList();

  final transformedInitializers = extDecl.initializers
      .map((i) => transformInitializer(i, wrappedInstance, parentNamer, state))
      .toList();

  final transformedExt = ExtensionDeclaration(
    id: extDecl.id.addIdSuffix('wrapper'),
    name: extDecl.name,
    source: extDecl.source,
    availability: extDecl.availability,
    extendedType: transformedTarget.asDeclaredType,
    methods: [
      ...transformedMethods.removeWhereType<MethodDeclaration>(),
      ...transformedProperties.removeWhereType<MethodDeclaration>(),
      ...transformedInitializers.removeWhereType<MethodDeclaration>(),
    ].sortedById(),
    properties: transformedProperties
        .removeWhereType<PropertyDeclaration>()
        .sortedById(),
    initializers: transformedInitializers
        .removeWhereType<InitializerDeclaration>()
        .sortedById(),
  );

  if (transformedExt.methods.isEmpty &&
      transformedExt.properties.isEmpty &&
      transformedExt.initializers.isEmpty) {
    return null;
  }

  state.map[extDecl] = transformedExt;
  return transformedExt;
}
