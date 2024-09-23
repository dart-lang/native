// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_referred_type.dart';

MethodDeclaration transformMethod(
  MethodDeclaration originalMethod,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final transformedParams = originalMethod.params
      .map(
        (param) => Parameter(
          name: param.name,
          internalName: param.internalName,
          type: transformReferredType(
            param.type,
            globalNamer,
            transformationMap,
          ),
        ),
      )
      .toList();

  final ReferredType? transformedReturnType;

  if (originalMethod.returnType == null) {
    transformedReturnType = null;
  } else {
    transformedReturnType = transformReferredType(
      originalMethod.returnType!,
      globalNamer,
      transformationMap,
    );
  }

  final transformedMethod = MethodDeclaration(
    id: originalMethod.id,
    name: originalMethod.name,
    returnType: transformedReturnType,
    params: transformedParams,
    hasObjCAnnotation: true,
    isStatic: originalMethod.isStatic,
  );

  transformedMethod.statements = _generateMethodStatements(
    originalMethod,
    wrappedClassInstance,
    transformedMethod,
    globalNamer,
    transformationMap,
  );

  return transformedMethod;
}

List<String> _generateMethodStatements(
  MethodDeclaration originalMethod,
  PropertyDeclaration wrappedClassInstance,
  MethodDeclaration transformedMethod,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final argumentsList = <String>[];

  for (var i = 0; i < originalMethod.params.length; i++) {
    final originalParam = originalMethod.params[i];
    final transformedParam = transformedMethod.params[i];

    final transformedParamName =
        transformedParam.internalName ?? transformedParam.name;

    final (unwrappedParamValue, unwrappedType) = maybeUnwrapValue(
      transformedParam.type,
      transformedParamName,
    );

    assert(unwrappedType.id == originalParam.type.id);

    var methodCallArg = '${originalParam.name}: $unwrappedParamValue';

    argumentsList.add(methodCallArg);
  }

  final arguments = argumentsList.join(', ');

  final methodSource = originalMethod.isStatic
      ? wrappedClassInstance.type.name
      : wrappedClassInstance.name;
  final originalMethodCall = '$methodSource.${originalMethod.name}($arguments)';

  if (originalMethod.returnType == null) {
    return [originalMethodCall];
  }

  if (originalMethod.returnType!.id == transformedMethod.returnType?.id) {
    return ['return $originalMethodCall'];
  }

  if (originalMethod.returnType is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final methodCallStmt = 'let result = $originalMethodCall';

  final (wrappedResult, wrapperType) = maybeWrapValue(
    originalMethod.returnType!,
    'result',
    globalNamer,
    transformationMap,
  );

  assert(transformedMethod.returnType?.id == wrapperType.id);

  final returnStmt = 'return $wrappedResult';

  return [
    methodCallStmt,
    returnStmt,
  ];
}
