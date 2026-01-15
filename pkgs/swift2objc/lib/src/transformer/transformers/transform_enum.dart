// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/enum_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../_core/utils.dart';
import '../transform.dart';
import 'transform_compound.dart';
import 'transform_function.dart';
import 'transform_variable.dart';

ClassDeclaration transformEnum(
  EnumDeclaration enumDecl,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  final wrapper = transformCompound(enumDecl, parentNamer, state);

  // Transform enum cases to methods and properties. If the case has associated
  // values it becomes a method, otherwise it becomes a property. For each case,
  // first create a fake method/property, then transform the fake. Note that
  // transforming a property may also generate a method instead of a property.
  final cases = enumDecl.cases
      .map((c) => _transformEnumCase(c, enumDecl, wrapper, parentNamer, state))
      .nonNulls
      .sortedById();
  wrapper.methods.addAll(cases.removeWhereType<MethodDeclaration>());
  wrapper.properties.addAll(cases.removeWhereType<PropertyDeclaration>());
  assert(cases.isEmpty);

  return wrapper;
}

Declaration? _transformEnumCase(
  EnumCaseDeclaration caseDecl,
  EnumDeclaration enumDecl,
  ClassDeclaration wrapper,
  UniqueNamer parentNamer,
  TransformationState state,
) {
  if (caseDecl.params.isEmpty) {
    return transformProperty(
      PropertyDeclaration(
        id: caseDecl.id,
        name: caseDecl.name,
        source: caseDecl.source,
        availability: caseDecl.availability,
        type: enumDecl.asDeclaredType,
        hasSetter: false,
        isConstant: true,
        isStatic: true,
      ),
      wrapper.wrappedInstance!,
      parentNamer,
      state,
    );
  } else {
    return transformMethod(
      MethodDeclaration(
        id: caseDecl.id,
        name: caseDecl.name,
        source: caseDecl.source,
        availability: caseDecl.availability,
        returnType: enumDecl.asDeclaredType,
        params: caseDecl.params
            .map((param) => Parameter(name: param.name, type: param.type))
            .toList(),
        isStatic: true,
      ),
      wrapper.wrappedInstance!,
      parentNamer,
      state,
    );
  }
}
