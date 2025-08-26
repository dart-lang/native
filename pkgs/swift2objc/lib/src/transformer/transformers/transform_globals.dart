// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/method_declaration.dart';
import '../../ast/declarations/compounds/members/property_declaration.dart';
import '../../ast/declarations/globals/globals.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';
import 'transform_function.dart';
import 'transform_variable.dart';

ClassDeclaration? transformGlobals(
  Globals globals,
  UniqueNamer globalNamer,
  TransformationState state,
) {
  if (globals.variables.isEmpty && globals.functions.isEmpty) return null;

  final transformedGlobals = ClassDeclaration(
    id: 'globals'.addIdSuffix('wrapper'),
    name: globalNamer.makeUnique('GlobalsWrapper'),
    availability: const [],
    hasObjCAnnotation: true,
    superClass: objectType,
    isWrapper: true,
  );

  final transformedProperties = globals.variables
      .map((variable) => transformGlobalVariable(variable, globalNamer, state))
      .toList();

  final transformedMethods = globals.functions
      .map((function) => transformGlobalFunction(function, globalNamer, state))
      .toList();

  transformedGlobals.properties =
      transformedProperties.whereType<PropertyDeclaration>().toList()
        ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  transformedGlobals.methods =
      (transformedMethods +
            transformedProperties.whereType<MethodDeclaration>().toList())
        ..sort((Declaration a, Declaration b) => a.id.compareTo(b.id));

  return transformedGlobals;
}
