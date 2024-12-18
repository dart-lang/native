// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_referred_type.dart';

InitializerDeclaration transformInitializer(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final transformedParams = originalInitializer.params
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

  final transformedInitializer = InitializerDeclaration(
      id: originalInitializer.id,
      params: transformedParams,
      hasObjCAnnotation: true,
      isFailable: originalInitializer.isFailable,
      throws: originalInitializer.throws,
      async: originalInitializer.async,
      // Because the wrapper class extends NSObject that has an initializer with
      // no parameters. If we make a similar parameterless initializer we need
      // to add `override` keyword.
      isOverriding: transformedParams.isEmpty);

  transformedInitializer.statements = _generateInitializerStatements(
    originalInitializer,
    wrappedClassInstance,
    transformedInitializer,
  );

  return transformedInitializer;
}

List<String> _generateInitializerStatements(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  InitializerDeclaration transformedInitializer,
) {
  final localNamer = UniqueNamer();
  final arguments = generateInvocationParams(
      localNamer, originalInitializer.params, transformedInitializer.params);
  var instanceConstruction =
      '${wrappedClassInstance.type.swiftType}($arguments)';
  if (transformedInitializer.async) {
    instanceConstruction = 'await $instanceConstruction';
  }
  if (transformedInitializer.throws) {
    instanceConstruction = 'try $instanceConstruction';
  }
  if (originalInitializer.isFailable) {
    final instance = localNamer.makeUnique('instance');
    return [
      'if let $instance = $instanceConstruction {',
      '  ${wrappedClassInstance.name} = $instance',
      '} else {',
      '  return nil',
      '}',
    ];
  } else {
    return ['${wrappedClassInstance.name} = $instanceConstruction'];
  }
}
