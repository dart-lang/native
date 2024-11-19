// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/compound_declaration.dart';
import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_initializer.dart';
import 'transform_variable.dart';

ClassDeclaration transformCompound(
  CompoundDeclaration originalCompound,
  UniqueNamer globalNamer,
  TransformationMap transformationMap,
) {
  final compoundNamer = UniqueNamer.inCompound(originalCompound);

  final wrappedCompoundInstance = PropertyDeclaration(
    id: originalCompound.id.addIdSuffix('wrappedInstance'),
    name: compoundNamer.makeUnique('wrappedInstance'),
    type: originalCompound.asDeclaredType,
  );

  final transformedCompound = ClassDeclaration(
    id: originalCompound.id.addIdSuffix('wrapper'),
    name: globalNamer.makeUnique('${originalCompound.name}Wrapper'),
    hasObjCAnnotation: true,
    superClass: BuiltInDeclaration.swiftNSObject.asDeclaredType,
    isWrapper: true,
    wrappedInstance: wrappedCompoundInstance,
    wrapperInitializer: _buildWrapperInitializer(wrappedCompoundInstance),
  );

  transformationMap[originalCompound] = transformedCompound;

  transformedCompound.properties = originalCompound.properties
      .map((property) => transformProperty(
            property,
            wrappedCompoundInstance,
            globalNamer,
            transformationMap,
          ))
      .nonNulls
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedCompound.initializers = originalCompound.initializers
      .map((initializer) => transformInitializer(
            initializer,
            wrappedCompoundInstance,
            globalNamer,
            transformationMap,
          ))
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedCompound.methods = originalCompound.methods
      .map((method) => transformMethod(
            method,
            wrappedCompoundInstance,
            globalNamer,
            transformationMap,
          ))
      .nonNulls
      .toList()
    ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedCompound;
}

InitializerDeclaration _buildWrapperInitializer(
  PropertyDeclaration wrappedClassInstance,
) {
  return InitializerDeclaration(
    id: '',
    params: [
      Parameter(
        name: '_',
        internalName: 'wrappedInstance',
        type: wrappedClassInstance.type,
      )
    ],
    isOverriding: false,
    isFailable: false,
    statements: ['self.${wrappedClassInstance.name} = wrappedInstance'],
    hasObjCAnnotation: wrappedClassInstance.hasObjCAnnotation,
  );
}
