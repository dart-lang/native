// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';
import 'package:swift2objc/src/ast/declarations/compounds/class_declaration.dart';
import 'package:swift2objc/src/parser/_core/utils.dart';
import 'package:swift2objc/src/transformer/transform.dart';
import 'package:swift2objc/src/transformer/transformers/transform_method.dart';

ClassDeclaration transformClass(
  ClassDeclaration originalClass,
  TransformationMap transformationMap,
) {
  final wrappedClassInstance = getWrappedInstanceProperty(originalClass);

  final transformedClass = ClassDeclaration(
    id: originalClass.id.addIdSuffix("wrapper"),
    name: "${originalClass.name}Wrapper",
    properties: [wrappedClassInstance],
    hasObjCAnnotation: true,
    superClass: BuiltInDeclarations.NSObject.asDeclaredType,
    isWrapper: true,
    wrappedInstance: wrappedClassInstance,
  );

  transformationMap[originalClass] = transformedClass;

  transformedClass.methods = originalClass.methods
      .map((method) => transformMethod(
            method,
            wrappedClassInstance,
            transformationMap,
          ))
      .toList();
  return transformedClass;
}

ClassPropertyDeclaration getWrappedInstanceProperty(
  ClassDeclaration originalClass,
) {
  final memberNames = <String>{
    ...originalClass.methods.map((method) => method.name),
    ...originalClass.properties.map((property) => property.name),
  };

  var wrappedInstanceName = "wrappedInstance";

  while (memberNames.contains(wrappedInstanceName)) {
    wrappedInstanceName = "_" + wrappedInstanceName;
  }

  return ClassPropertyDeclaration(
    id: originalClass.id.addIdSuffix("wrapper").addIdSuffix("reference"),
    name: wrappedInstanceName,
    type: originalClass.asDeclaredType,
  );
}
