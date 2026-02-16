// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/typealias_declaration.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';

// TODO(https://github.com/dart-lang/native/issues/1358): Refactor this as a
// transformer or visitor.

ReferredType transformReferredType(
  ReferredType type,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  if (type.isObjCRepresentable) return type;

  if (type is TupleType) {
    return _transformTupleType(type, globalNamer, state);
  } else if (type is GenericType) {
    throw UnimplementedError('Generic types are not supported yet');
  } else if (type is DeclaredType) {
    final decl = type.declaration;
    if (decl is TypealiasDeclaration) {
      return transformReferredType(decl.target, globalNamer, state);
    }
    return transformDeclaration(decl, globalNamer, state).asDeclaredType;
  } else if (type is OptionalType) {
    return OptionalType(transformReferredType(type.child, globalNamer, state));
  } else {
    throw UnimplementedError('Unknown type: $type');
  }
}

DeclaredType _transformTupleType(
  TupleType tupleType,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final signature = tupleType.swiftType;

  if (state.tupleWrappers.containsKey(signature)) {
    return state.tupleWrappers[signature]!.asDeclaredType;
  }

  final className = _generateTupleClassName(tupleType, globalNamer, state);

  final wrapperClass = _generateTupleWrapperClass(
    tupleType,
    className,
    globalNamer,
    state,
  );

  state.tupleWrappers[signature] = wrapperClass;

  return wrapperClass.asDeclaredType;
}

String _generateTupleClassName(
  TupleType tuple,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final parts = <String>[];

  for (var i = 0; i < tuple.elements.length; i++) {
    final element = tuple.elements[i];
    if (element.label != null) {
      parts.add('${element.label}_${_sanitizeTypeName(element.type)}');
    } else {
      parts.add(_sanitizeTypeName(element.type));
    }
  }

  return globalNamer.makeUnique('Tuple_${parts.join('_')}');
}

String _sanitizeTypeName(ReferredType type) {
  return type.swiftType
      .replaceAll('<', '_')
      .replaceAll('?', 'Optional')
      .replaceAll('[', 'Array_')
      .replaceAll(RegExp(r'[^\w]'), '');
}

ClassDeclaration _generateTupleWrapperClass(
  TupleType tupleType,
  String className,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final properties = <PropertyDeclaration>[];

  final wrappedInstanceProperty = PropertyDeclaration(
    id: 'tuple_${className}_wrappedInstance',
    name: 'wrappedInstance',
    source: null,
    availability: const [],
    type: tupleType,
    hasSetter: false,
    isConstant: false,
    hasObjCAnnotation: false,
    isStatic: false,
    throws: false,
    async: false,
    unowned: false,
    lazy: false,
    weak: false,
  );

  for (var i = 0; i < tupleType.elements.length; i++) {
    final element = tupleType.elements[i];
    final propertyName = element.label ?? '_$i';

    final transformedType = transformReferredType(
      element.type,
      globalNamer,
      state,
    );

    final property = PropertyDeclaration(
      id: 'tuple_${className}_$propertyName',
      name: propertyName,
      source: null,
      availability: const [],
      type: transformedType,
      hasSetter: false,
      isConstant: false,
      hasObjCAnnotation: true,
      isStatic: false,
      throws: false,
      async: false,
      unowned: false,
      lazy: false,
      weak: false,
    );

    final accessor = element.label != null
        ? 'wrappedInstance.${element.label}'
        : 'wrappedInstance.$i';

    final (wrappedValue, _) = maybeWrapValue(
      element.type,
      accessor,
      globalNamer,
      state,
    );

    property.getter = PropertyStatements([wrappedValue]);

    properties.add(property);
  }

  return ClassDeclaration(
    id: 'tuple_wrapper_$className',
    name: className,
    source: null,
    availability: const [],
    superClass: objectType,
    properties: properties,
    wrappedInstance: wrappedInstanceProperty,
    wrapperInitializer: buildWrapperInitializer(wrappedInstanceProperty),
    hasObjCAnnotation: true,
  );
}
