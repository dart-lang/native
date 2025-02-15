// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../parser/_core/utils.dart';
import '../../transformer/_core/utils.dart';
import '../transform.dart';

final primitiveWrappers = <ReferredType, ReferredType>{
  intType: _createWrapperClass(intType),
  floatType: _createWrapperClass(floatType),
  doubleType: _createWrapperClass(doubleType),
  boolType: _createWrapperClass(boolType),
};

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
  bool isThrows,
  TransformationMap transformationMap,
) {
  if (type is! DeclaredType || !_isPrimitiveType(type) || !isThrows) {
    return (type, false);
  }

  final wrapper = getPrimitiveWrapper(type);
  transformationMap[type.declaration] = (wrapper as DeclaredType).declaration;
  return (wrapper, true);
}

ReferredType getPrimitiveWrapper(DeclaredType other) {
  return primitiveWrappers.entries
      .firstWhere(
        (entry) => entry.key.sameAs(other),
      )
      .value;
}

bool _isPrimitiveType(DeclaredType type) {
  return type.name == 'Int' ||
      type.name == 'Float' ||
      type.name == 'Double' ||
      type.name == 'Bool';
}
