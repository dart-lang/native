// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/extension_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_member.dart';

Declaration? transformExtension(
  ExtensionDeclaration extDecl,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  final transformedTarget = transformDeclaration(
    extDecl.extendedType.declaration,
    parentNamer,
    state,
  );

  if (transformedTarget is! ClassDeclaration) {
    return _transformExternalExtension(extDecl, parentNamer, state);
  }

  final wrappedInstance = transformedTarget.wrappedInstance;
  if (wrappedInstance == null) return null;

  final (properties, initializers, methods) = transformMembers(
    properties: extDecl.properties,
    initializers: extDecl.initializers,
    methods: extDecl.methods,
    wrappedInstance: wrappedInstance,
    namer: parentNamer,
    state: state,
    initializersAreConvenience: true,
  );

  final transformedExt = ExtensionDeclaration(
    id: extDecl.id.addIdSuffix('wrapper'),
    name: extDecl.name,
    source: extDecl.source,
    availability: extDecl.availability,
    extendedType: transformedTarget.asDeclaredType,
    methods: methods,
    properties: properties,
    initializers: initializers,
  );

  if (transformedExt.methods.isEmpty &&
      transformedExt.properties.isEmpty &&
      transformedExt.initializers.isEmpty) {
    return null;
  }

  state.map[extDecl] = transformedExt;
  return transformedExt;
}

ClassDeclaration? _transformExternalExtension(
  ExtensionDeclaration extDecl,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  // External types have no generated wrapper that can carry a wrappedInstance.
  // Expose their instance extension methods as static methods instead.
  final methods = extDecl.methods
      .map(
        (method) => transformExternalExtensionMethod(
          method,
          extDecl.extendedType,
          parentNamer,
          state,
        ),
      )
      .nonNulls
      .toList();

  if (methods.isEmpty) return null;

  final helper = ClassDeclaration(
    id: extDecl.id.addIdSuffix('helper'),
    name: parentNamer.makeUnique('${extDecl.name}Extensions'),
    source: extDecl.source,
    availability: extDecl.availability,
    hasObjCAnnotation: true,
    superClass: objectType,
    methods: methods,
  );
  state.map[extDecl] = helper;
  return helper;
}
