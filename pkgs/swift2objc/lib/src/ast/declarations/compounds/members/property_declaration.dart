// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/executable.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/interfaces/variable_declaration.dart';
import '../../../_core/shared/referred_type.dart';

/// Describes a property declaration for a Swift compound entity
/// (e.g, class, structs)
class PropertyDeclaration implements VariableDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  bool hasObjCAnnotation;

  @override
  ReferredType type;

  @override
  bool isConstant;

  bool hasSetter;

  PropertyStatements? getter;
  PropertyStatements? setter;

  bool isStatic;

  PropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    this.hasSetter = false,
    this.isConstant = false,
    this.hasObjCAnnotation = false,
    this.getter,
    this.setter,
    this.isStatic = false,
  }) : assert(!isConstant || !hasSetter);
}

class PropertyStatements implements Executable {
  @override
  final List<String> statements;

  PropertyStatements(this.statements);
}
