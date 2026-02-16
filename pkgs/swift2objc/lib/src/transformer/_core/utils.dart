// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/typealias_declaration.dart';
import '../../transformer/_core/primitive_wrappers.dart';
import '../transform.dart';
import '../transformers/transform_referred_type.dart';
import 'unique_namer.dart';

// TODO(https://github.com/dart-lang/native/issues/1358): These functions should
// probably be methods on ReferredType, but the transformDeclaration call makes
// that weird. Refactor this as part of the transformer refactor.

(String value, ReferredType type) maybeWrapValue(
  ReferredType type,
  String value,
  UniqueNamer globalNamer,
  TransformationState state, {
  bool shouldWrapPrimitives = false,
}) {
  // Handle tuple types first
  if (type is TupleType) {
    return _wrapTupleValue(type, value, globalNamer, state);
  }

  final (wrappedPrimitiveType, returnsWrappedPrimitive) =
      maybeGetPrimitiveWrapper(type, shouldWrapPrimitives, state);
  if (returnsWrappedPrimitive) {
    return (
      '${(wrappedPrimitiveType as DeclaredType).name}($value)',
      wrappedPrimitiveType,
    );
  }

  if (type.isObjCRepresentable) {
    return (value, type);
  }

  if (type is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  } else if (type is DeclaredType) {
    final declaration = type.declaration;
    if (declaration is TypealiasDeclaration) {
      return maybeWrapValue(
        declaration.target,
        value,
        globalNamer,
        state,
        shouldWrapPrimitives: shouldWrapPrimitives,
      );
    }

    final transformedTypeDeclaration = transformDeclaration(
      declaration,
      globalNamer,
      state,
    );

    return (
      '${transformedTypeDeclaration.name}($value)',
      transformedTypeDeclaration.asDeclaredType,
    );
  } else if (type is OptionalType) {
    final (newValue, newType) = maybeWrapValue(
      type.child,
      '$value!',
      globalNamer,
      state,
    );
    return ('$value == nil ? nil : $newValue', OptionalType(newType));
  } else {
    throw UnimplementedError('Unknown type: $type');
  }
}

(String, ReferredType) _wrapTupleValue(
  TupleType tupleType,
  String tupleExpression,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final wrapperType = transformReferredType(tupleType, globalNamer, state);
  final wrapperClass =
      (wrapperType as DeclaredType).declaration as ClassDeclaration;

  return ('${wrapperClass.name}($tupleExpression)', wrapperType);
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
    } else if (declaration is TypealiasDeclaration) {
      return maybeUnwrapValue(declaration.target, value);
    } else {
      return (value, type);
    }
  } else if (type is OptionalType) {
    final optValue = '$value?';
    var (newValue, newType) = maybeUnwrapValue(type.child, optValue);
    if (newValue == optValue) {
      // newValue is value?, so the ? isn't necessary and causes compile errors.
      newValue = value;
    }
    return (newValue, OptionalType(newType));
  } else {
    throw UnimplementedError('Unknown type: $type');
  }
}

InitializerDeclaration buildWrapperInitializer(
  PropertyDeclaration wrappedClassInstance,
) {
  return InitializerDeclaration(
    id: '',
    source: wrappedClassInstance.source,
    availability: const [],
    params: [
      Parameter(
        name: '_',
        internalName: 'wrappedInstance',
        type: wrappedClassInstance.type,
      ),
    ],
    isOverriding: false,
    isFailable: false,
    throws: false,
    async: false,
    statements: ['self.${wrappedClassInstance.name} = wrappedInstance'],
    hasObjCAnnotation: wrappedClassInstance.hasObjCAnnotation,
  );
}

extension SortById<T extends Declaration> on Iterable<T> {
  List<T> sortedById() => toList()..sort((T a, T b) => a.id.compareTo(b.id));
}
