// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/function_declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'const.dart';
import 'transform_referred_type.dart';

/// Wrapper generation strategy: For both methods and global functions, we
/// create a primary wrapper with all parameters, then additional overloads
/// that omit trailing parameters with default values. This allows ObjC
/// callers to avoid passing default arguments explicitly.
///
/// The key difference:
///   - Methods reference the original through a wrapped class instance
///   - Global functions reference the original directly

MethodDeclaration? transformMethod(
  MethodDeclaration originalMethod,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  if (disallowedMethods.contains(originalMethod.name)) {
    return null;
  }

  final methods = _transformFunction(
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

  return methods.isEmpty ? null : methods.first;
}

List<MethodDeclaration> transformMethodWithOverloads(
  MethodDeclaration originalMethod,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  if (disallowedMethods.contains(originalMethod.name)) {
    return const [];
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
  final methods = _transformFunction(
    globalFunction,
    globalNamer,
    state,
    wrapperMethodName: globalNamer.makeUnique('${globalFunction.name}Wrapper'),
    originalCallStatementGenerator: (arguments) =>
        '${globalFunction.name}($arguments)',
  );
  return methods.first;
}

List<MethodDeclaration> transformGlobalFunctionWithOverloads(
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

/// Counts the number of trailing parameters with default values.
///
/// ObjC doesn't support default parameters, so we generate overloads
/// omitting each combination of trailing defaults. For example, a function
/// with signature `foo(a, b=1, c=2)` generates overloads for `foo(a, b)`
/// and `foo(a)`.
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

/// Transforms a Swift function/method into one or more ObjC wrapper methods.
///
/// Returns a list containing:
///   - The primary wrapper with all parameters
///   - Zero or more overloads omitting trailing default parameters
///
/// This centralized implementation eliminates duplication between method,
/// initializer, and global function transformation paths.
List<MethodDeclaration> _transformFunction(
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

  // Generate overloads for trailing default parameters. Each overload omits
  // one more trailing default, allowing ObjC callers to use them without
  // explicitly passing default arguments.
  final trailingDefaults = _trailingDefaultCount(originalFunction.params);
  if (trailingDefaults == 0) {
    return [transformedMethod];
  }

  final allMethods = <MethodDeclaration>[transformedMethod];

  for (
    var parametersToOmit = 1;
    parametersToOmit <= trailingDefaults;
    ++parametersToOmit
  ) {
    final parameterCount = originalFunction.params.length - parametersToOmit;
    final overloadParams = transformedMethod.params.sublist(0, parameterCount);

    final overloadNamer = UniqueNamer();
    final overloadResultName = overloadNamer.makeUnique('result');
    final (overloadWrapperResult, _) = maybeWrapValue(
      originalFunction.returnType,
      overloadResultName,
      globalNamer,
      state,
      shouldWrapPrimitives: originalFunction.throws,
    );

    final overload = MethodDeclaration(
      id: originalFunction.id.addIdSuffix('default$parametersToOmit'),
      name: wrapperMethodName,
      source: originalFunction.source,
      availability: originalFunction.availability,
      returnType: transformedMethod.returnType,
      params: overloadParams,
      hasObjCAnnotation: true,
      isStatic: originalFunction is MethodDeclaration
          ? originalFunction.isStatic
          : true,
      throws: originalFunction.throws,
      async: originalFunction.async,
    );

    overload.statements = _generateStatementsWithParamSubset(
      originalFunction,
      overload,
      globalNamer,
      overloadNamer,
      overloadResultName,
      overloadWrapperResult,
      state,
      originalCallGenerator: originalCallStatementGenerator,
      originalParamsForCall: originalFunction.params.sublist(0, parameterCount),
      transformedParamsForCall: overloadParams,
    );

    allMethods.add(overload);
  }

  return allMethods;
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
