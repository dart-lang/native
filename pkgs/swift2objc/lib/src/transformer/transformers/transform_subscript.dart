// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/compounds/members/subscript_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

List<Declaration> transformSubscript(
  SubscriptDeclaration originalSubscript,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  if (_isSubscriptRepresentable(originalSubscript)) {
    final originalParam = originalSubscript.params.single;
    final paramName =
        originalParam.internalName ??
        (originalParam.name == '_' ? 'index' : originalParam.name);

    final transformedParam = Parameter(
      name: '_',
      internalName: paramName,
      type: transformReferredType(originalParam.type, globalNamer, state),
    );

    final localNamer = UniqueNamer();
    final resultName = localNamer.makeUnique('result');

    final (unwrappedIndex, _) = maybeUnwrapValue(
      transformedParam.type,
      paramName,
    );

    final (wrappedResult, returnType) = maybeWrapValue(
      originalSubscript.returnType,
      resultName,
      globalNamer,
      state,
    );

    final getterStatements = [
      'let $resultName = ${wrappedClassInstance.name}[$unwrappedIndex]',
      'return $wrappedResult',
    ];

    PropertyStatements? setterStatements;
    if (originalSubscript.hasSetter) {
      final (unwrappedNewValue, _) = maybeUnwrapValue(returnType, 'newValue');
      setterStatements = PropertyStatements([
        '${wrappedClassInstance.name}[$unwrappedIndex] = $unwrappedNewValue',
      ]);
    }

    return [
      SubscriptDeclaration(
        id: originalSubscript.id,
        source: originalSubscript.source,
        lineNumber: originalSubscript.lineNumber,
        availability: originalSubscript.availability,
        returnType: returnType,
        params: [transformedParam],
        hasObjCAnnotation: true,
        hasSetter: originalSubscript.hasSetter,
        isStatic: false,
        throws: false,
        async: false,
        mutating: false,
        getter: PropertyStatements(getterStatements),
        setter: setterStatements,
      ),
    ];
  }

  final transformedParams = [
    for (var i = 0; i < originalSubscript.params.length; ++i)
      Parameter(
        name: originalSubscript.params[i].name.isEmpty
            ? '_'
            : originalSubscript.params[i].name,
        internalName:
            originalSubscript.params[i].name.isEmpty &&
                originalSubscript.params[i].internalName == null
            ? 'arg$i'
            : originalSubscript.params[i].internalName,
        type: transformReferredType(
          originalSubscript.params[i].type,
          globalNamer,
          state,
        ),
      ),
  ];

  final localNamer = UniqueNamer();
  final resultName = localNamer.makeUnique('result');

  final (wrappedResult, returnType) = maybeWrapValue(
    originalSubscript.returnType,
    resultName,
    globalNamer,
    state,
    shouldWrapPrimitives: originalSubscript.throws,
  );

  final arguments = generateInvocationParams(
    localNamer,
    originalSubscript.params,
    transformedParams,
  );

  final target = originalSubscript.isStatic
      ? wrappedClassInstance.type.swiftType
      : wrappedClassInstance.name;

  var getterCall = '$target[$arguments]';
  if (originalSubscript.async) {
    getterCall = 'await $getterCall';
  }
  if (originalSubscript.throws) {
    getterCall = 'try $getterCall';
  }

  final List<String> getterStatements;
  if (originalSubscript.returnType.sameAs(returnType)) {
    getterStatements = ['return $getterCall'];
  } else {
    getterStatements = [
      'let $resultName = $getterCall',
      'return $wrappedResult',
    ];
  }

  final getterMethod = MethodDeclaration(
    id: originalSubscript.id.addIdSuffix('getValue'),
    name: 'getValue',
    source: originalSubscript.source,
    lineNumber: originalSubscript.lineNumber,
    availability: originalSubscript.availability,
    returnType: returnType,
    params: transformedParams,
    hasObjCAnnotation: true,
    isStatic: originalSubscript.isStatic,
    throws: originalSubscript.throws,
    async: originalSubscript.async,
    statements: getterStatements,
  );

  MethodDeclaration? setterMethod;
  if (originalSubscript.hasSetter) {
    final setterParams = [
      ...transformedParams,
      Parameter(name: 'newValue', internalName: null, type: returnType),
    ];

    final (unwrappedNewValue, _) = maybeUnwrapValue(returnType, 'newValue');

    var setterCall = '$target[$arguments] = $unwrappedNewValue';
    if (originalSubscript.async) {
      setterCall = 'await $setterCall';
    }
    if (originalSubscript.throws) {
      setterCall = 'try $setterCall';
    }

    setterMethod = MethodDeclaration(
      id: originalSubscript.id.addIdSuffix('setValue'),
      name: 'setValue',
      source: originalSubscript.source,
      lineNumber: originalSubscript.lineNumber,
      availability: originalSubscript.availability,
      returnType: voidType,
      params: setterParams,
      hasObjCAnnotation: true,
      isStatic: originalSubscript.isStatic,
      throws: originalSubscript.throws,
      async: originalSubscript.async,
      statements: [setterCall],
    );
  }

  return [getterMethod, ?setterMethod];
}

bool _isSubscriptRepresentable(SubscriptDeclaration subscript) {
  if (subscript.isStatic || subscript.throws || subscript.async) {
    return false;
  }
  if (subscript.params.length != 1) {
    return false;
  }
  final paramType = subscript.params.first.type;
  if (paramType.sameAs(intType)) {
    return true;
  }
  return paramType.isObjCRepresentable && paramType is! OptionalType;
}
