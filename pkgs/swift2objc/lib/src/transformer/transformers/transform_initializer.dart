// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
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
  );

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
  final argumentsList = <String>[];

  for (var i = 0; i < originalInitializer.params.length; i++) {
    final originalParam = originalInitializer.params[i];
    final transformedParam = transformedInitializer.params[i];

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

  final instanceConstruction = '${wrappedClassInstance.type.name}($arguments)';
  return ['${wrappedClassInstance.name} = $instanceConstruction'];
}
