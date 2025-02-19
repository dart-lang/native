// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../parser/_core/utils.dart';
import '../../transformer/_core/utils.dart';
import '../transform.dart';

ReferredType _createWrapperClass(DeclaredType primitiveType) {
  final property = PropertyDeclaration(
    id: primitiveType.id.addIdSuffix('wrappedInstance'),
    name: 'wrappedInstance',
    type: primitiveType,
  );
  return ClassDeclaration(
          id: primitiveType.id.addIdSuffix('wrapper'),
          name: '${primitiveType.name}Wrapper',
          hasObjCAnnotation: true,
          superClass: objectType,
          isWrapper: true,
          wrappedInstance: property,
          wrapperInitializer: buildWrapperInitializer(property))
      .asDeclaredType;
}

// Support Optional primitives as return Type
// TODO(https://github.com/dart-lang/native/issues/1743)

(ReferredType, bool) getWrapperIfNeeded(
  ReferredType type,
  bool shouldWrapPrimitives,
  TransformationMap transformationMap,
) {
  if (type is! DeclaredType || !shouldWrapPrimitives) {
    return (type, false);
  }

  final wrapper = getPrimitiveWrapper(type);
  if (wrapper == null) {
    return (type, false);
  }

  transformationMap[type.declaration] = (wrapper as DeclaredType).declaration;
  return (wrapper, true);
}

ReferredType? getPrimitiveWrapper(DeclaredType other) {
  final primitiveWrappers = <(ReferredType, ReferredType)>[
    (intType, _createWrapperClass(intType)),
    (floatType, _createWrapperClass(floatType)),
    (doubleType, _createWrapperClass(doubleType)),
    (boolType, _createWrapperClass(boolType)),
  ];

  return primitiveWrappers
      .firstWhereOrNull((pair) => pair.$1.sameAs(other))
      ?.$2;
}
