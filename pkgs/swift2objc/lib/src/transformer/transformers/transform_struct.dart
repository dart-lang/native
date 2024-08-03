// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/compounds/struct_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_method.dart';
import 'transform_property.dart';

ClassDeclaration transformStruct(
  StructDeclaration originalStruct,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final structNamer = UniqueNamer.inCompound(originalStruct);

  final wrappedStructInstance = PropertyDeclaration(
    id: originalStruct.id.addIdSuffix('wrapper-reference'),
    name: structNamer.makeUnique('wrappedInstance'),
    type: originalStruct.asDeclaredType,
  );

  final transformedClass = ClassDeclaration(
    id: originalStruct.id.addIdSuffix('wrapper'),
    name: globalNamer.makeUnique('${originalStruct.name}Wrapper'),
    properties: [wrappedStructInstance],
    hasObjCAnnotation: true,
    superClass: BuiltInDeclarations.swiftNSObject.asDeclaredType,
    isWrapper: true,
    wrappedInstance: wrappedStructInstance,
    initializer: _buildWrapperInitializer(wrappedStructInstance),
  );

  transformationMap[originalStruct] = transformedClass;

  transformedClass.methods = originalStruct.methods
      .map((method) => transformMethod(
            method,
            wrappedStructInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedClass.properties = originalStruct.properties
      .map((property) => transformProperty(
            property,
            wrappedStructInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedClass;
}

Initializer _buildWrapperInitializer(PropertyDeclaration wrappedClassInstance) {
  return Initializer(
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
