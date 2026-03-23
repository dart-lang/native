// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/extension_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_member.dart';

ExtensionDeclaration? transformExtension(
  ExtensionDeclaration extDecl,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  final transformedTarget = transformDeclaration(
    extDecl.extendedType.declaration,
    parentNamer,
    state,
  );

  if (transformedTarget is! ClassDeclaration) return null;

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
