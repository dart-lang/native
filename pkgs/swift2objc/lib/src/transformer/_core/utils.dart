// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../transform.dart';
import 'unique_namer.dart';

// TODO(https://github.com/dart-lang/native/issues/1358): These functions should
// probably be methods on ReferredType, but the transformDeclaration call makes
// that weird. Refactor this as part of the transformer refactor.

(String value, ReferredType type) maybeWrapValue(
  ReferredType type,
  String value,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (type.isObjCRepresentable) {
    return (value, type);
  }

  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  } else if (type is DeclaredType) {
    final transformedTypeDeclaration = transformDeclaration(
      type.declaration,
      globalNamer,
      transformationMap,
    );

    return (
      '${transformedTypeDeclaration.name}($value)',
      transformedTypeDeclaration.asDeclaredType
    );
  } else if (type is OptionalType) {
    final (newValue, newType) =
        maybeWrapValue(type.child, '$value!', globalNamer, transformationMap);
    return (
      '$value == nil ? nil : $newValue',
      OptionalType(newType),
    );
  } else {
    throw UnimplementedError('Unknown type: $type');
  }
}

(String value, ReferredType type) maybeUnwrapValue(
  ReferredType type,
  String value,
) {
  if (!type.isObjCRepresentable) {
    return (value, type);
  }

  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  } else if (type is DeclaredType) {
    final declaration = type.declaration;
    if (declaration is ClassDeclaration) {
      final wrappedInstance = declaration.wrappedInstance!;
      return ('$value.${wrappedInstance.name}', wrappedInstance.type);
    } else {
      return (value, type);
    }
  } else if (type is OptionalType) {
    final (newValue, newType) = maybeUnwrapValue(type.child, '$value?');
    return (newValue, OptionalType(newType));
  } else {
    throw UnimplementedError('Unknown type: $type');
  }
}
