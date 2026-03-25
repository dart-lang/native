// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_initializer.dart';
import 'transform_variable.dart';

(
  List<PropertyDeclaration> properties,
  List<InitializerDeclaration> initializers,
  List<MethodDeclaration> methods,
)
transformMembers({
  required List<PropertyDeclaration> properties,
  required List<InitializerDeclaration> initializers,
  required List<MethodDeclaration> methods,
  required PropertyDeclaration wrappedInstance,
  required UniqueNamer namer,
  required TransformationState state,
  bool initializersAreConvenience = false,
}) {
  final transformedMethods = methods
      .map((m) => transformMethod(m, wrappedInstance, namer, state))
      .nonNulls
      .toList();

  final transformedProperties = properties
      .map((p) => transformProperty(p, wrappedInstance, namer, state))
      .nonNulls
      .toList();

  final transformedInitializers = initializers
      .map(
        (i) => transformInitializer(
          i,
          wrappedInstance,
          namer,
          state,
          isConvenience: initializersAreConvenience,
        ),
      )
      .toList();

  final allTransformed = [
    ...transformedMethods,
    ...transformedProperties,
    ...transformedInitializers,
  ];

  return (
    allTransformed.whereType<PropertyDeclaration>().sortedById(),
    allTransformed.whereType<InitializerDeclaration>().sortedById(),
    allTransformed.whereType<MethodDeclaration>().sortedById(),
  );
}
