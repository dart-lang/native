// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/function_declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'const.dart';
import 'transform_referred_type.dart';

// The main difference between generating a wrapper method for a global function
// and a compound method is the way the original function/method is referenced.
// In compound method case, the original method is referenced through the
// wrapped class instance in the wrapper class. In global function case,
// it can be referenced directly since it's not a member of any entity.

MethodDeclaration? transformMethod(
  MethodDeclaration originalMethod,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  if (disallowedMethods.contains(originalMethod.name)) {
    return null;
  }

  return _transformFunction(
    originalMethod,
    globalNamer,
    transformationMap,
    wrapperMethodName: originalMethod.name,
    originalCallStatementGenerator: (arguments) {
      final methodSource = originalMethod.isStatic
          ? wrappedClassInstance.type.swiftType
          : wrappedClassInstance.name;
      return '$methodSource.${originalMethod.name}($arguments)';
    },
  );
}

MethodDeclaration transformGlobalFunction(
  GlobalFunctionDeclaration globalFunction,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  return _transformFunction(
    globalFunction,
    globalNamer,
    transformationMap,
    wrapperMethodName: globalNamer.makeUnique(
      '${globalFunction.name}Wrapper',
    ),
    originalCallStatementGenerator: (arguments) =>
        '${globalFunction.name}($arguments)',
  );
}

// -------------------------- Core Implementation --------------------------

MethodDeclaration _transformFunction(
  FunctionDeclaration originalFunction,
  UniqueNamer globalNamer,
  TransformationMap transformationMap, {
  required String wrapperMethodName,
  required String Function(String arguments) originalCallStatementGenerator,
}) {
  final transformedParams = originalFunction.params
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

  final transformedReturnType = transformReferredType(
    originalFunction.returnType,
    globalNamer,
    transformationMap,
  );

  final transformedMethod = MethodDeclaration(
    id: originalFunction.id,
    name: wrapperMethodName,
    returnType: transformedReturnType,
    params: transformedParams,
    hasObjCAnnotation: true,
    isStatic: originalFunction is MethodDeclaration
        ? originalFunction.isStatic
        : true,
  );

  transformedMethod.statements = _generateStatements(
    originalFunction,
    transformedMethod,
    globalNamer,
    transformationMap,
    originalCallGenerator: originalCallStatementGenerator,
  );

  return transformedMethod;
}

List<String> _generateStatements(
  FunctionDeclaration originalFunction,
  MethodDeclaration transformedMethod,
  UniqueNamer globalNamer,
  TransformationMap transformationMap, {
  required String Function(String arguments) originalCallGenerator,
}) {
  final argumentsList = <String>[];

  for (var i = 0; i < originalFunction.params.length; i++) {
    final originalParam = originalFunction.params[i];
    final transformedParam = transformedMethod.params[i];

    final transformedParamName =
        transformedParam.internalName ?? transformedParam.name;

    final (unwrappedParamValue, unwrappedType) = maybeUnwrapValue(
      transformedParam.type,
      transformedParamName,
    );

    assert(unwrappedType.sameAs(originalParam.type));

    var methodCallArg = '${originalParam.name}: $unwrappedParamValue';

    argumentsList.add(methodCallArg);
  }

  final arguments = argumentsList.join(', ');

  final originalMethodCall = originalCallGenerator(arguments);

  if (originalFunction.returnType.sameAs(transformedMethod.returnType)) {
    return ['return $originalMethodCall'];
  }

  if (originalFunction.returnType is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  final methodCallStmt = 'let result = $originalMethodCall';

  final (wrappedResult, wrapperType) = maybeWrapValue(
    originalFunction.returnType,
    'result',
    globalNamer,
    transformationMap,
  );

  assert(wrapperType.sameAs(transformedMethod.returnType));

  final returnStmt = 'return $wrappedResult';

  return [
    methodCallStmt,
    returnStmt,
  ];
}
