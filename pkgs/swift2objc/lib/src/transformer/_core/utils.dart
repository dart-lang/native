// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../transform.dart';
import 'unique_namer.dart';

(String value, ReferredType type) maybeWrapValue(
  ReferredType type,
  String valueIdentifier,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  type as DeclaredType;

  if (type.isObjCRepresentable) {
    return (valueIdentifier, type);
  }

  final transformedTypeDeclaration = transformDeclaration(
    type.declaration,
    globalNamer,
    transformationMap,
  );

  return (
    '${transformedTypeDeclaration.name}($valueIdentifier)',
    transformedTypeDeclaration.asDeclaredType
  );
}

(String value, ReferredType type) maybeUnwrapValue(
  ReferredType type,
  String valueIdentifier,
) {
  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final declaration = (type as DeclaredType).declaration;

  if (declaration is ClassDeclaration && declaration.wrappedInstance != null) {
    final wrappedInstance = declaration.wrappedInstance;
    return ('$valueIdentifier.${wrappedInstance!.name}', wrappedInstance.type);
  } else {
    return (valueIdentifier, type);
  }
}
