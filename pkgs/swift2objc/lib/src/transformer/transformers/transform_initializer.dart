// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_referred_type.dart';

Declaration transformInitializer(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final declarations = transformInitializerWithOverloads(
    originalInitializer,
    wrappedClassInstance,
    globalNamer,
    state,
  );
  return declarations.first;
}

List<Declaration> transformInitializerWithOverloads(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  final transformedParams = originalInitializer.params
      .map(
        (param) => Parameter(
          name: param.name,
          internalName: param.internalName,
          type: transformReferredType(param.type, globalNamer, state),
          defaultValue: param.defaultValue,
        ),
      )
      .toList();

  final Declaration mainDeclaration;

  if (originalInitializer.async) {
    final methodReturnType = transformReferredType(
      wrappedClassInstance.type,
      globalNamer,
      state,
    );

    mainDeclaration = MethodDeclaration(
      id: originalInitializer.id,
      name: '${originalInitializer.name}Wrapper',
      source: originalInitializer.source,
      availability: originalInitializer.availability,
      returnType: originalInitializer.isFailable
          ? OptionalType(methodReturnType)
          : methodReturnType,
      params: transformedParams,
      hasObjCAnnotation: true,
      statements: _generateMethodStatements(
        originalInitializer,
        wrappedClassInstance,
        methodReturnType,
        transformedParams,
      ),
      throws: originalInitializer.throws,
      async: originalInitializer.async,
      isStatic: true,
    );
  } else {
    final transformedInitializer = InitializerDeclaration(
      id: originalInitializer.id,
      source: originalInitializer.source,
      availability: originalInitializer.availability,
      params: transformedParams,
      hasObjCAnnotation: true,
      isFailable: originalInitializer.isFailable,
      throws: originalInitializer.throws,
      async: originalInitializer.async,
      isOverriding: transformedParams.isEmpty,
    );

    transformedInitializer.statements = _generateInitializerStatements(
      originalInitializer,
      wrappedClassInstance,
      transformedInitializer,
    );

    mainDeclaration = transformedInitializer;
  }

  // Generate overloads for trailing default parameters
  final defaults = _trailingDefaultCount(originalInitializer.params);
  if (defaults == 0) {
    return [mainDeclaration];
  }

  final declarations = <Declaration>[mainDeclaration];

  for (var drop = 1; drop <= defaults; ++drop) {
    final keep = originalInitializer.params.length - drop;
    final transformedSubsetParams = originalInitializer.params
        .sublist(0, keep)
        .map(
          (param) => Parameter(
            name: param.name,
            internalName: param.internalName,
            type: transformReferredType(param.type, globalNamer, state),
            defaultValue: param.defaultValue,
          ),
        )
        .toList();

    if (originalInitializer.async) {
      // Generate async method wrapper overload
      final methodReturnType = transformReferredType(
        wrappedClassInstance.type,
        globalNamer,
        state,
      );

      final over = MethodDeclaration(
        id: originalInitializer.id.addIdSuffix('default$drop'),
        name: '${originalInitializer.name}Wrapper',
        source: originalInitializer.source,
        availability: originalInitializer.availability,
        returnType: originalInitializer.isFailable
            ? OptionalType(methodReturnType)
            : methodReturnType,
        params: transformedSubsetParams,
        hasObjCAnnotation: true,
        throws: originalInitializer.throws,
        async: originalInitializer.async,
        isStatic: true,
      );

      over.statements = _generateMethodStatements(
        originalInitializer,
        wrappedClassInstance,
        methodReturnType,
        transformedSubsetParams,
      );
      declarations.add(over);
    } else {
      // Generate regular initializer overload
      final over = InitializerDeclaration(
        id: originalInitializer.id.addIdSuffix('default$drop'),
        source: originalInitializer.source,
        availability: originalInitializer.availability,
        params: transformedSubsetParams,
        hasObjCAnnotation: true,
        isFailable: originalInitializer.isFailable,
        throws: originalInitializer.throws,
        async: originalInitializer.async,
        isOverriding: transformedSubsetParams.isEmpty,
      );

      over.statements = _generateInitializerStatementsWithSubset(
        originalInitializer,
        wrappedClassInstance,
        over,
        originalInitializer.params.sublist(0, keep),
      );
      declarations.add(over);
    }
  }

  return declarations;
}

List<String> _generateInitializerStatements(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  InitializerDeclaration transformedInitializer,
) {
  final (instanceConstruction, localNamer) = _generateInstanceConstruction(
    originalInitializer,
    wrappedClassInstance,
    transformedInitializer.params,
  );
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

List<String> _generateMethodStatements(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  ReferredType wrapperClass,
  List<Parameter> transformedParams,
) {
  final (instanceConstruction, localNamer) = _generateInstanceConstruction(
    originalInitializer,
    wrappedClassInstance,
    transformedParams,
  );
  final instance = localNamer.makeUnique('instance');
  if (originalInitializer.isFailable) {
    return [
      'if let $instance = $instanceConstruction {',
      '  return ${wrapperClass.swiftType}($instance)',
      '} else {',
      '  return nil',
      '}',
    ];
  } else {
    return [
      'let $instance = $instanceConstruction',
      'return ${wrapperClass.swiftType}($instance)',
    ];
  }
}

(String, UniqueNamer) _generateInstanceConstruction(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  List<Parameter> transformedParams,
) {
  final localNamer = UniqueNamer();
  final arguments = generateInvocationParams(
    localNamer,
    originalInitializer.params,
    transformedParams,
  );
  var instanceConstruction =
      '${wrappedClassInstance.type.swiftType}($arguments)';
  if (originalInitializer.async) {
    instanceConstruction = 'await $instanceConstruction';
  }
  if (originalInitializer.throws) {
    instanceConstruction = 'try $instanceConstruction';
  }
  return (instanceConstruction, localNamer);
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

List<String> _generateInitializerStatementsWithSubset(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  InitializerDeclaration transformedInitializer,
  List<Parameter> originalParamsSubset,
) {
  final (
    instanceConstruction,
    localNamer,
  ) = _generateInstanceConstructionWithSubset(
    originalInitializer,
    wrappedClassInstance,
    transformedInitializer.params,
    originalParamsSubset,
  );
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

(String, UniqueNamer) _generateInstanceConstructionWithSubset(
  InitializerDeclaration originalInitializer,
  PropertyDeclaration wrappedClassInstance,
  List<Parameter> transformedParams,
  List<Parameter> originalParamsSubset,
) {
  final localNamer = UniqueNamer();
  final arguments = generateInvocationParams(
    localNamer,
    originalParamsSubset,
    transformedParams,
  );
  var instanceConstruction =
      '${wrappedClassInstance.type.swiftType}($arguments)';
  if (originalInitializer.async) {
    instanceConstruction = 'await $instanceConstruction';
  }
  if (originalInitializer.throws) {
    instanceConstruction = 'try $instanceConstruction';
  }
  return (instanceConstruction, localNamer);
}
