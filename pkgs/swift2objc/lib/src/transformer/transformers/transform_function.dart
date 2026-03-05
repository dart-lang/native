// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/function_declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
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
  if (originalMethod.isOperator &&
      originalMethod.params.any((p) => p.type.sameAs(selfType))) {
    return null;
  }

  final wrapperMethodName = originalMethod.isOperator
      ? globalNamer.makeUnique(originalMethod.name)
      : originalMethod.name;

  return _transformFunction(
    originalMethod,
    globalNamer,
    state,
    wrapperMethodName: wrapperMethodName,
    originalCallStatementGenerator: (arguments) {
      final methodSource = originalMethod.isStatic
          ? wrappedClassInstance.type.swiftType
          : wrappedClassInstance.name;

      if (originalMethod.isOperator) {
        final params = originalMethod.params;
        return '${params[0].internalName ?? params[0].name}.wrappedInstance '
            '${originalMethod.name} '
            '${params[1].internalName ?? params[1].name}.wrappedInstance';
      }

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

Parameter _transformParam(
  int index,
  Parameter p,
  UniqueNamer globalNamer,
  TransformationState state,
) => Parameter(
  name: p.name.isEmpty ? '_' : p.name,
  internalName: p.name.isEmpty && p.internalName == null
      ? 'arg$index'
      : p.internalName,
  type: transformReferredType(p.type, globalNamer, state),
);

MethodDeclaration _transformFunction(
  FunctionDeclaration originalFunction,
  UniqueNamer globalNamer,
  TransformationState state, {
  required String wrapperMethodName,
  required String Function(String arguments) originalCallStatementGenerator,
}) {
  final transformedParams = [
    for (var i = 0; i < originalFunction.params.length; ++i)
      _transformParam(i, originalFunction.params[i], globalNamer, state),
  ];

  final localNamer = UniqueNamer();
  final resultName = localNamer.makeUnique('result');
  final transformedReturnType = transformReferredType(
    originalFunction.returnType,
    globalNamer,
    state,
  );

  final (wrapperResult, type) = switch ((
    originalFunction.returnType,
    transformedReturnType,
  )) {
    (ClosureType originalClosure, ClosureType transformedClosure)
        when !originalClosure.sameAs(transformedClosure) => (
          _adaptClosureForWrapperReturn(
            originalClosure,
            transformedClosure,
            resultName,
            localNamer,
            globalNamer,
            state,
          ),
          transformedReturnType,
        ),
    _ => maybeWrapValue(
      originalFunction.returnType,
      resultName,
      globalNamer,
      state,
      shouldWrapPrimitives: originalFunction.throws,
    ),
  };

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
  UniqueNamer globalNamer,
  TransformationState state,
) {
  assert(originalParams.length == transformedParams.length);

  final argumentsList = <String>[];
  for (var i = 0; i < originalParams.length; i++) {
    final originalParam = originalParams[i];
    final transformedParam = transformedParams[i];

    final transformedParamName = localNamer.makeUnique(
      transformedParam.internalName ?? transformedParam.name,
    );

    final (unwrappedParamValue, unwrappedType) = switch ((
      originalParam.type,
      transformedParam.type,
    )) {
      (ClosureType originalClosure, ClosureType transformedClosure)
          when !originalClosure.sameAs(transformedClosure) => (
            _adaptClosureForInvocation(
              originalClosure,
              transformedClosure,
              transformedParamName,
              localNamer,
              globalNamer,
              state,
            ),
            originalParam.type,
          ),
      _ => maybeUnwrapValue(transformedParam.type, transformedParamName),
    };

    assert(unwrappedType.sameAs(originalParam.type));
    final invocationValue = originalParam.type is InoutType
        ? '&$unwrappedParamValue'
        : unwrappedParamValue;

    argumentsList.add(
      originalParam.name.isEmpty || originalParam.name == '_'
          ? invocationValue
          : '${originalParam.name}: $invocationValue',
    );
  }
  return argumentsList.join(', ');
}


String _closureEffects(ClosureType closureType) {
  final effects = [
    if (closureType.isAsync) 'async',
    if (closureType.isThrowing) 'throws',
  ];
  return effects.isEmpty ? '' : ' ${effects.join(' ')}';
}

String _adaptClosureForInvocation(
  ClosureType originalClosure,
  ClosureType transformedClosure,
  String transformedClosureName,
  UniqueNamer localNamer,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  assert(originalClosure.parameters.length == transformedClosure.parameters.length);

  final parameterDecls = <String>[];
  final invocationArgs = <String>[];

  for (var i = 0; i < originalClosure.parameters.length; i++) {
    final originalType = originalClosure.parameters[i];
    final transformedType = transformedClosure.parameters[i];
    final argName = localNamer.makeUnique('closureArg$i');
    parameterDecls.add('$argName: ${originalType.swiftType}');

    final (wrappedArg, wrappedType) = maybeWrapValue(
      originalType,
      argName,
      globalNamer,
      state,
    );
    assert(wrappedType.sameAs(transformedType));
    invocationArgs.add(wrappedArg);
  }

  var callExpression = '$transformedClosureName(${invocationArgs.join(', ')})';
  if (originalClosure.isAsync) callExpression = 'await $callExpression';
  if (originalClosure.isThrowing) callExpression = 'try $callExpression';

  if (originalClosure.returnType.sameAs(voidType)) {
    return '{ (${parameterDecls.join(', ')})${_closureEffects(originalClosure)} in $callExpression }';
  }

  final (unwrappedReturn, unwrappedType) = maybeUnwrapValue(
    transformedClosure.returnType,
    callExpression,
  );
  assert(unwrappedType.sameAs(originalClosure.returnType));

  return '{ (${parameterDecls.join(', ')})${_closureEffects(originalClosure)} in return $unwrappedReturn }';
}

String _adaptClosureForWrapperReturn(
  ClosureType originalClosure,
  ClosureType transformedClosure,
  String originalClosureName,
  UniqueNamer localNamer,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  assert(originalClosure.parameters.length == transformedClosure.parameters.length);

  final parameterDecls = <String>[];
  final invocationArgs = <String>[];

  for (var i = 0; i < transformedClosure.parameters.length; i++) {
    final transformedType = transformedClosure.parameters[i];
    final originalType = originalClosure.parameters[i];
    final argName = localNamer.makeUnique('closureArg$i');
    parameterDecls.add('$argName: ${transformedType.swiftType}');

    final (unwrappedArg, unwrappedType) = maybeUnwrapValue(transformedType, argName);
    assert(unwrappedType.sameAs(originalType));
    invocationArgs.add(unwrappedArg);
  }

  var callExpression = '$originalClosureName(${invocationArgs.join(', ')})';
  if (originalClosure.isAsync) callExpression = 'await $callExpression';
  if (originalClosure.isThrowing) callExpression = 'try $callExpression';

  if (transformedClosure.returnType.sameAs(voidType)) {
    return '{ (${parameterDecls.join(', ')})${_closureEffects(transformedClosure)} in $callExpression }';
  }

  final (wrappedReturn, wrappedType) = maybeWrapValue(
    originalClosure.returnType,
    callExpression,
    globalNamer,
    state,
  );
  assert(wrappedType.sameAs(transformedClosure.returnType));

  return '{ (${parameterDecls.join(', ')})${_closureEffects(transformedClosure)} in return $wrappedReturn }';
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
  final arguments = generateInvocationParams(
    localNamer,
    originalFunction.params,
    transformedMethod.params,
    globalNamer,
    state,
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
