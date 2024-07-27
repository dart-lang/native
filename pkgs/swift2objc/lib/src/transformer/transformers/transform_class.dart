// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_method.dart';
import 'transform_property.dart';

ClassDeclaration transformClass(
  ClassDeclaration originalClass,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final classNamer = UniqueNamer.inClass(originalClass);

  final wrappedClassInstance = ClassPropertyDeclaration(
    id: originalClass.id.addIdSuffix('wrapper-reference'),
    name: classNamer.makeUnique('wrappedInstance'),
    type: originalClass.asDeclaredType,
  );

  final transformedClass = ClassDeclaration(
    id: originalClass.id.addIdSuffix('wrapper'),
    name: globalNamer.makeUnique('${originalClass.name}Wrapper'),
    properties: [wrappedClassInstance],
    hasObjCAnnotation: true,
    superClass: BuiltInDeclarations.swiftNSObject.asDeclaredType,
    isWrapper: true,
    wrappedInstance: wrappedClassInstance,
    initializer: _buildWrapperInitializer(wrappedClassInstance),
  );

  transformationMap[originalClass] = transformedClass;

  transformedClass.methods = originalClass.methods
      .map((method) => transformMethod(
            method,
            wrappedClassInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));
  
  transformedClass.properties = originalClass.properties
      .map((property) => transformProperty(
            property,
            wrappedClassInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedClass;
}

ClassInitializer _buildWrapperInitializer(
    ClassPropertyDeclaration wrappedClassInstance) {
  return ClassInitializer(
    params: [
      Parameter(
        name: '_',
        internalName: 'wrappedInstance',
        type: wrappedClassInstance.type,
      )
    ],
    statements: ['self.${wrappedClassInstance.name} = wrappedInstance'],
  );
}
