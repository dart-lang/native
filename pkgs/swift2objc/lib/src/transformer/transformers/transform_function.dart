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
  TransformationState state,
) {
  if (disallowedMethods.contains(originalMethod.name)) {
    return null;
  }

  return _transformFunction(
    originalMethod,
    globalNamer,
    state,
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
  TransformationState state,
) {
  return _transformFunction(
    globalFunction,
    globalNamer,
    state,
    wrapperMethodName: globalNamer.makeUnique('${globalFunction.name}Wrapper'),
    originalCallStatementGenerator: (arguments) =>
        '${globalFunction.name}($arguments)',
  );
}

// -------------------------- Core Implementation --------------------------

MethodDeclaration _transformFunction(
  FunctionDeclaration originalFunction,
  UniqueNamer globalNamer,
  TransformationState state, {
  required String wrapperMethodName,
  required String Function(String arguments) originalCallStatementGenerator,
}) {
  final transformedParams = originalFunction.params
      .map(
        (param) => Parameter(
          name: param.name,
          internalName: param.internalName,
          type: transformReferredType(param.type, globalNamer, state),
          defaultValue: param.defaultValue,
        ),
      )
      .toList();

  final localNamer = UniqueNamer();
  final resultName = localNamer.makeUnique('result');

  final (wrapperResult, type) = maybeWrapValue(
    originalFunction.returnType,
    resultName,
    globalNamer,
    state,
    shouldWrapPrimitives: originalFunction.throws,
  );

  final transformedMethod = MethodDeclaration(
    id: originalFunction.id,
    name: wrapperMethodName,
    source: originalFunction.source,
    availability: originalFunction.availability,
    returnType: type,
    params: transformedParams,
    hasObjCAnnotation: true,
    isStatic: originalFunction is MethodDeclaration
        ? originalFunction.isStatic
        : true,
    throws: originalFunction.throws,
    async: originalFunction.async,
  );

  transformedMethod.statements = _generateStatements(
    originalFunction,
    transformedMethod,
    globalNamer,
    localNamer,
    resultName,
    wrapperResult,
    state,
    originalCallGenerator: originalCallStatementGenerator,
  );

  return transformedMethod;
}

String generateInvocationParams(
  UniqueNamer localNamer,
  List<Parameter> originalParams,
  List<Parameter> transformedParams,
) {
  assert(originalParams.length == transformedParams.length);

  final argumentsList = <String>[];
  for (var i = 0; i < originalParams.length; i++) {
    final originalParam = originalParams[i];
    final transformedParam = transformedParams[i];

    final transformedParamName = localNamer.makeUnique(
      transformedParam.internalName ?? transformedParam.name,
    );

    final (unwrappedParamValue, unwrappedType) = maybeUnwrapValue(
      transformedParam.type,
      transformedParamName,
    );

    assert(unwrappedType.sameAs(originalParam.type));

    argumentsList.add(
      originalParam.name == '_'
          ? unwrappedParamValue
          : '${originalParam.name}: $unwrappedParamValue',
    );
  }
  return argumentsList.join(', ');
}

List<String> _generateStatements(
  FunctionDeclaration originalFunction,
  MethodDeclaration transformedMethod,
  UniqueNamer globalNamer,
  UniqueNamer localNamer,
  String resultName,
  String wrappedResult,
  TransformationState state, {
  required String Function(String arguments) originalCallGenerator,
}) {
  return _generateStatementsWithParamSubset(
    originalFunction,
    transformedMethod,
    globalNamer,
    localNamer,
    resultName,
    wrappedResult,
    state,
    originalCallGenerator: originalCallGenerator,
    originalParamsForCall: originalFunction.params,
    transformedParamsForCall: transformedMethod.params,
  );
}

List<String> _generateStatementsWithParamSubset(
  FunctionDeclaration originalFunction,
  MethodDeclaration transformedMethod,
  UniqueNamer globalNamer,
  UniqueNamer localNamer,
  String resultName,
  String wrappedResult,
  TransformationState state, {
  required String Function(String arguments) originalCallGenerator,
  required List<Parameter> originalParamsForCall,
  required List<Parameter> transformedParamsForCall,
}) {
  final arguments = generateInvocationParams(
    localNamer,
    originalParamsForCall,
    transformedParamsForCall,
  );
  var originalMethodCall = originalCallGenerator(arguments);
  if (transformedMethod.async) {
    originalMethodCall = 'await $originalMethodCall';
  }
  if (transformedMethod.throws) {
    originalMethodCall = 'try $originalMethodCall';
  }

  if (originalFunction.returnType.sameAs(transformedMethod.returnType)) {
    return ['return $originalMethodCall'];
  }

  if (originalFunction.returnType is GenericType) {
    throw UnimplementedError('Generic types are not implemented yet');
  }

  return ['let $resultName = $originalMethodCall', 'return $wrappedResult'];
}

int _trailingDefaultCount(List<Parameter> params) {
  var count = 0;
  for (var i = params.length - 1; i >= 0; --i) {
    if (params[i].defaultValue != null) {
      count++;
    } else {
      break;
    }
  }
  return count;
}

List<MethodDeclaration> buildDefaultOverloadsForMethod(
  MethodDeclaration originalMethod,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state, {
  required MethodDeclaration baseTransformed,
}) {
  final defaults = _trailingDefaultCount(originalMethod.params);
  if (defaults == 0) return const [];

  final overloads = <MethodDeclaration>[];
  for (var drop = 1; drop <= defaults; ++drop) {
    final keep = originalMethod.params.length - drop;
    final transformedSubset = baseTransformed.params.sublist(0, keep);

    final over = MethodDeclaration(
      id: '${originalMethod.id}-default$drop',
      name: baseTransformed.name,
      source: originalMethod.source,
      availability: originalMethod.availability,
      returnType: baseTransformed.returnType,
      params: transformedSubset,
      hasObjCAnnotation: true,
      isStatic: originalMethod.isStatic,
      throws: originalMethod.throws,
      async: originalMethod.async,
    );

    final localNamer = UniqueNamer();
    final resultName = localNamer.makeUnique('result');
    final (wrapperResult, _) = maybeWrapValue(
      originalMethod.returnType,
      resultName,
      globalNamer,
      state,
      shouldWrapPrimitives: originalMethod.throws,
    );
    final methodSource = originalMethod.isStatic
        ? wrappedClassInstance.type.swiftType
        : wrappedClassInstance.name;
    over.statements = _generateStatementsWithParamSubset(
      originalMethod,
      over,
      globalNamer,
      localNamer,
      resultName,
      wrapperResult,
      state,
      originalCallGenerator: (args) => '$methodSource.${originalMethod.name}($args)',
      originalParamsForCall: originalMethod.params.sublist(0, keep),
      transformedParamsForCall: transformedSubset,
    );
    overloads.add(over);
  }
  return overloads;
}

List<MethodDeclaration> buildDefaultOverloadsForGlobalFunction(
  GlobalFunctionDeclaration globalFunction,
  MethodDeclaration baseTransformed,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final defaults = _trailingDefaultCount(globalFunction.params);
  if (defaults == 0) return const [];
  final overloads = <MethodDeclaration>[];
  for (var drop = 1; drop <= defaults; ++drop) {
    final keep = globalFunction.params.length - drop;
    final subset = baseTransformed.params.sublist(0, keep);
    final over = MethodDeclaration(
      id: '${globalFunction.id}-default$drop',
      name: baseTransformed.name,
      source: globalFunction.source,
      availability: globalFunction.availability,
      returnType: baseTransformed.returnType,
      params: subset,
      hasObjCAnnotation: true,
      isStatic: true,
      throws: globalFunction.throws,
      async: globalFunction.async,
    );

    final localNamer = UniqueNamer();
    final resultName = localNamer.makeUnique('result');
    final (wrapperResult, _) = maybeWrapValue(
      globalFunction.returnType,
      resultName,
      globalNamer,
      state,
      shouldWrapPrimitives: globalFunction.throws,
    );
    over.statements = _generateStatementsWithParamSubset(
      globalFunction,
      over,
      globalNamer,
      localNamer,
      resultName,
      wrapperResult,
      state,
      originalCallGenerator: (args) => '${globalFunction.name}($args)',
      originalParamsForCall: globalFunction.params.sublist(0, keep),
      transformedParamsForCall: subset,
    );
    overloads.add(over);
  }
  return overloads;
}
