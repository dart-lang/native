// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/shared/parameter.dart';
import 'package:swift2objc/src/ast/_core/shared/referred_type.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_referred_type.dart';

ClassMethodDeclaration transformMethod(
  ClassMethodDeclaration originalMethod,
  ClassPropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final transformedParams = originalMethod.params
      .map((param) => _transformParamter(param, globalNamer, transformationMap))
      .toList();

  final transformedMethod = ClassMethodDeclaration(
    id: originalMethod.id,
    name: originalMethod.name,
    returnType: transformReferredType(
      originalMethod.returnType,
      globalNamer,
      transformationMap,
    ),
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
  ClassMethodDeclaration originalMethod,
  ClassPropertyDeclaration wrappedClassInstance,
  ClassMethodDeclaration transformedMethod,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
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

  final methodReturnType = originalMethod.returnType;

  final originalMethodCall =
      "${wrappedClassInstance.name}.${originalMethod.name}(${arguments.join(", ")})";

  if (methodReturnType.isObjCRepresentable) {
    return ["return $originalMethodCall"];
  }

  if (methodReturnType is GenericType) {
    throw UnimplementedError("Generic types are not implemented yet");
  }

  final transformedReturnTypeDeclaration = transformDeclaration(
    (methodReturnType as DeclaredType).declaration,
    globalNamer,
    transformationMap,
  );

  assert(
    transformedReturnTypeDeclaration is! ClassDeclaration,
    "A method call result can only be wrapped in a class",
  );

  final methodCallStmt = "let result = $originalMethodCall";

  final wrapperConstructionStmt =
      "let wrappedResult = ${transformedReturnTypeDeclaration.name}(result)";

  final returnStmt = "return wrappedResult";

  return [
    methodCallStmt,
    wrapperConstructionStmt,
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
