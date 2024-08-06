// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_method.dart';
import 'transform_property.dart';

ClassDeclaration transformCompound(
  CompoundDeclaration originalCompound,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final classNamer = UniqueNamer.inCompound(originalCompound);

  final wrappedCompoundInstance = PropertyDeclaration(
    id: originalCompound.id.addIdSuffix('wrapper-reference'),
    name: classNamer.makeUnique('wrappedInstance'),
    type: originalCompound.asDeclaredType,
  );

  final transformedCompound = ClassDeclaration(
    id: originalCompound.id.addIdSuffix('wrapper'),
    name: globalNamer.makeUnique('${originalCompound.name}Wrapper'),
    properties: [wrappedCompoundInstance],
    hasObjCAnnotation: true,
    superClass: BuiltInDeclarations.swiftNSObject.asDeclaredType,
    isWrapper: true,
    wrappedInstance: wrappedCompoundInstance,
    initializer: _buildWrapperInitializer(wrappedCompoundInstance),
  );

  transformationMap[originalCompound] = transformedCompound;

  transformedCompound.methods = originalCompound.methods
      .map((method) => transformMethod(
            method,
            wrappedCompoundInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedCompound.properties = originalCompound.properties
      .map((property) => transformProperty(
            property,
            wrappedCompoundInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedCompound;
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
