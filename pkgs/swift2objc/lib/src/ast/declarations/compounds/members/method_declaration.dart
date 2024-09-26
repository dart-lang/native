// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/declaration.dart';
import '../../../_core/interfaces/executable.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/interfaces/parameterizable.dart';
import '../../../_core/interfaces/type_parameterizable.dart';
import '../../../_core/shared/parameter.dart';
import '../../../_core/shared/referred_type.dart';

/// Describes a method declaration for a Swift compound entity
/// (e.g, class, structs)
class MethodDeclaration
    implements
        Declaration,
        TypeParameterizable,
        Executable,
        Parameterizable,
        ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> typeParams;

  @override
  bool hasObjCAnnotation;

  @override
  List<String> statements;

  ReferredType? returnType;

  bool isStatic;

  MethodDeclaration({
    required this.id,
    required this.name,
    required this.returnType,
    required this.params,
    this.typeParams = const [],
    this.hasObjCAnnotation = false,
    this.statements = const [],
    this.isStatic = false,
  });
}
