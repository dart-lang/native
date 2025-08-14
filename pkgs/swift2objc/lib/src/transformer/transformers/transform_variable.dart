// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/variable_declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'const.dart';
import 'transform_referred_type.dart';

// The main difference between generating a wrapper property for a global
// variable and a compound property is the way the original variable/property
// is referenced. In compound property case, the original property is referenced
// through the wrapped class instance in the wrapper class. In global variable
// case, it can be  referenced directly since it's not a member of any entity.

Declaration? transformProperty(
  PropertyDeclaration originalProperty,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (disallowedMethods.contains(originalProperty.name)) {
    return null;
  }

  final propertySource = originalProperty.isStatic
      ? wrappedClassInstance.type.swiftType
      : wrappedClassInstance.name;

  return _transformVariable(
    originalProperty,
    globalNamer,
    transformationMap,
    property: true,
    wrapperPropertyName: originalProperty.name,
    variableReferenceExpression: '$propertySource.${originalProperty.name}',
  );
}

Declaration transformGlobalVariable(
  GlobalVariableDeclaration globalVariable,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  return _transformVariable(
    globalVariable,
    globalNamer,
    transformationMap,
    wrapperPropertyName: globalNamer.makeUnique(
      '${globalVariable.name}Wrapper',
    ),
    variableReferenceExpression: globalVariable.name,
  );
}

// -------------------------- Core Implementation --------------------------

Declaration _transformVariable(
  VariableDeclaration originalVariable,
  UniqueNamer globalNamer,
  TransformationMap transformationMap, {
  bool property = false,
  required String wrapperPropertyName,
  required String variableReferenceExpression,
}) {
  final transformedType = transformReferredType(
    originalVariable.type,
    globalNamer,
    transformationMap,
  );

  final shouldGenerateSetter = originalVariable is PropertyDeclaration
      ? originalVariable.hasSetter
      : !originalVariable.isConstant;

  // properties that throw or are async need to be wrapped in a method
  if (originalVariable.throws || originalVariable.async) {
    final prefix = [
      if (originalVariable.throws) 'try',
      if (originalVariable.async) 'await'
    ].join(' ');

    final localNamer = UniqueNamer();
    final resultName = localNamer.makeUnique('result');

    final (wrapperResult, type) = maybeWrapValue(
        originalVariable.type, resultName, globalNamer, transformationMap,
        shouldWrapPrimitives: originalVariable.throws);

    return MethodDeclaration(
      id: originalVariable.id,
      name: wrapperPropertyName,
      availability: originalVariable.availability,
      returnType: type,
      params: [],
      hasObjCAnnotation: true,
      isStatic: originalVariable is PropertyDeclaration
          ? originalVariable.isStatic
          : true,
      statements: [
        'let $resultName = $prefix $variableReferenceExpression',
        'return $wrapperResult',
      ],
      throws: originalVariable.throws,
      async: originalVariable.async,
    );
  }

  final transformedProperty = PropertyDeclaration(
    id: originalVariable.id,
    name: wrapperPropertyName,
    availability: originalVariable.availability,
    type: transformedType,
    hasObjCAnnotation: true,
    hasSetter: shouldGenerateSetter,
    isStatic: originalVariable is PropertyDeclaration
        ? originalVariable.isStatic
        : true,
    isConstant: originalVariable.isConstant,
    throws: originalVariable.throws,
    async: originalVariable.async,
    unowned: originalVariable is PropertyDeclaration
        ? originalVariable.unowned
        : false,
    lazy:
        originalVariable is PropertyDeclaration ? originalVariable.lazy : false,
    weak:
        originalVariable is PropertyDeclaration ? originalVariable.weak : false,
  );

  final getterStatements = _generateGetterStatements(
    originalVariable,
    variableReferenceExpression,
    transformedProperty,
    globalNamer,
    transformationMap,
  );
  transformedProperty.getter = PropertyStatements(getterStatements);

  if (shouldGenerateSetter) {
    final setterStatements = _generateSetterStatements(
      originalVariable,
      variableReferenceExpression,
      transformedProperty,
      globalNamer,
      transformationMap,
    );
    transformedProperty.setter = PropertyStatements(setterStatements);
  }

  return transformedProperty;
}

List<String> _generateGetterStatements(
  VariableDeclaration originalVariable,
  String variableReferenceExpression,
  PropertyDeclaration transformedProperty,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final (wrappedValue, wrapperType) = maybeWrapValue(
    originalVariable.type,
    variableReferenceExpression,
    globalNamer,
    transformationMap,
  );

  assert(wrapperType.sameAs(transformedProperty.type));

  return [wrappedValue];
}

List<String> _generateSetterStatements(
  VariableDeclaration originalVariable,
  String variableReference,
  PropertyDeclaration transformedProperty,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final (unwrappedValue, unwrappedType) = maybeUnwrapValue(
    transformedProperty.type,
    'newValue',
  );

  assert(unwrappedType.sameAs(originalVariable.type),
      '$unwrappedType\tvs\t${originalVariable.type}');

  return ['$variableReference = $unwrappedValue'];
}
