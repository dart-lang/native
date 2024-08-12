// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
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
      .map((param) => _transformParamter(param, globalNamer, transformationMap))
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
    final original = originalMethod.params[i];
    final transformed = transformedMethod.params[i];

    var methodCallArg =
        '${original.name}: ${transformed.internalName ?? transformed.name}';

    final transformedType = transformed.type;
    if (transformedType is DeclaredType) {
      final typeDeclaration = transformedType.declaration;
      if (typeDeclaration is ClassDeclaration && typeDeclaration.isWrapper) {
        methodCallArg += '.${typeDeclaration.wrappedInstance!.name}';
      }
    }

    argumentsList.add(methodCallArg);
  }

  final methodReturnType = originalMethod.returnType;

  final arguments = argumentsList.join(', ');

  final originalMethodCall =
      '${wrappedClassInstance.name}.${originalMethod.name}($arguments)';

  if (methodReturnType == null) {
    return [originalMethodCall];
  }

  if (methodReturnType.isObjCRepresentable) {
    return ['return $originalMethodCall'];
  }

  if (methodReturnType is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final methodCallStmt = 'let result = $originalMethodCall';

  final (wrappedResult, wrapperType) = maybeWrapValue(
    methodReturnType,
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

Parameter _transformParamter(
  Parameter originalParameter,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  return Parameter(
    name: originalParameter.name,
    internalName: originalParameter.internalName,
    type: transformReferredType(
      originalParameter.type,
      globalNamer,
      transformationMap,
    ),
  );
}
