// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_referred_type.dart';

ClassMethodDeclaration transformMethod(
  ClassMethodDeclaration originalMethod,
  ClassPropertyDeclaration wrappedClassInstance,
  TransformationMap transformationMap,
) {
  final transformedParams = originalMethod.params
      .map((param) => _transformParamter(param, transformationMap))
      .toList();

  final transformedMethod = ClassMethodDeclaration(
    id: originalMethod.id,
    name: originalMethod.name,
    returnType: transformReferredType(
      originalMethod.returnType,
      transformationMap,
    ),
    params: transformedParams,
    hasObjCAnnotation: true,
  );

  transformedMethod.statements = <String>[
    _generateMethodCall(originalMethod, wrappedClassInstance, transformedMethod)
  ];

  return transformedMethod;
}

String _generateMethodCall(
  ClassMethodDeclaration originalMethod,
  ClassPropertyDeclaration wrappedClassInstance,
  ClassMethodDeclaration transformedMethod,
) {
  final arguments = <String>[];

  for (var i = 0; i < originalMethod.params.length; i++) {
    final originalParam = originalMethod.params[i];
    final transformedParam = transformedMethod.params[i];

    String methodCallArg =
        "${originalParam.name}: ${transformedParam.internalName ?? transformedParam.name}";

    final transformedType = transformedParam.type;
    if (transformedType is DeclaredType) {
      final typeDeclaration = transformedType.declaration;
      if (typeDeclaration is ClassDeclaration && typeDeclaration.isWrapper) {
        methodCallArg += ".${typeDeclaration.wrappedInstance!.name}";
      }
    }

    arguments.add(methodCallArg);
  }

  return "${wrappedClassInstance.name}.${originalMethod.name}(${arguments.join(", ")})";
}

Parameter _transformParamter(
  Parameter originalParameter,
  TransformationMap transformationMap,
) {
  return Parameter(
    name: originalParameter.name,
    internalName: originalParameter.internalName,
    type: transformReferredType(
      originalParameter.type,
      transformationMap,
    ),
  );
}
