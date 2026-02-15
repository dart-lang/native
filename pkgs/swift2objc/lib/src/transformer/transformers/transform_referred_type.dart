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
import '../_core/unique_namer.dart';
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
  final className = _generateTupleClassName(tupleType, globalNamer, state);

  if (state.hasGeneratedTuple(className)) {
    return state.getTupleWrapper(className).asDeclaredType;
  }

  final wrapperClass = _generateTupleWrapperClass(
    tupleType,
    className,
    globalNamer,
    state,
  );

  state.registerTupleWrapper(className, wrapperClass);

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
      .replaceAll('>', '')
      .replaceAll(',', '')
      .replaceAll(' ', '')
      .replaceAll('?', 'Optional')
      .replaceAll('[', 'Array_')
      .replaceAll(']', '');
}

ClassDeclaration _generateTupleWrapperClass(
  TupleType tupleType,
  String className,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final properties = <PropertyDeclaration>[];
  final initParams = <Parameter>[];
  final initStatements = <String>[];

  for (var i = 0; i < tupleType.elements.length; i++) {
    final element = tupleType.elements[i];
    final propertyName = element.label ?? '_$i';

    final transformedType = transformReferredType(
      element.type,
      globalNamer,
      state,
    );

    properties.add(
      PropertyDeclaration(
        id: 'tuple_${className}_$propertyName',
        name: propertyName,
        source: null,
        availability: const [],
        type: transformedType,
        hasSetter: false,
        isConstant: true,
        hasObjCAnnotation: false,
        isStatic: false,
        throws: false,
        async: false,
        unowned: false,
        lazy: false,
        weak: false,
      ),
    );

    initParams.add(Parameter(name: propertyName, type: transformedType));

    initStatements.add('self.$propertyName = $propertyName');
  }

  return ClassDeclaration(
    id: 'tuple_wrapper_$className',
    name: className,
    source: null,
    availability: const [],
    properties: properties,
    wrapperInitializer: InitializerDeclaration(
      id: 'tuple_wrapper_${className}_init',
      source: null,
      availability: const [],
      params: initParams,
      statements: initStatements,
      hasObjCAnnotation: true,
      isOverriding: false,
      isFailable: false,
      throws: false,
      async: false,
    ),
    hasObjCAnnotation: true,
  );
}
