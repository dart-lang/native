// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import 'protocol_declaration.dart';

/// Describes the declaration of a Swift class.
class ClassDeclaration implements CompoundDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<ClassPropertyDeclaration> properties;

  @override
  covariant List<ClassMethodDeclaration> methods;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  List<GenericType> typeParams;

  @override
  bool hasObjCAnnotation;

  DeclaredType<ClassDeclaration>? superClass;

  ClassDeclaration({
    required this.id,
    required this.name,
    List<ClassPropertyDeclaration>? properties,
    List<ClassMethodDeclaration>? methods,
    List<DeclaredType<ProtocolDeclaration>>? conformedProtocols,
    List<GenericType>? typeParams,
    this.hasObjCAnnotation = false,
    this.superClass,
  })  : this.properties = properties ?? [],
        this.methods = methods ?? [],
        this.conformedProtocols = conformedProtocols ?? [],
        this.typeParams = typeParams ?? [];
}

/// Describes the declaration of a property in a Swift class.
class ClassPropertyDeclaration
    implements CompoundPropertyDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  bool hasSetter;

  @override
  ReferredType type;

  @override
  bool hasObjCAnnotation;

  ClassPropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    this.hasSetter = false,
    this.hasObjCAnnotation = false,
  });
}

/// Describes the declaration of a method in a Swift class.
class ClassMethodDeclaration
    implements CompoundMethodDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> typeParams;

  @override
  ReferredType returnType;

  @override
  bool hasObjCAnnotation;

  ClassMethodDeclaration({
    required this.id,
    required this.name,
    required this.returnType,
    required this.params,
    List<GenericType>? typeParams,
    this.hasObjCAnnotation = false,
  }) : this.typeParams = typeParams ?? [];
}
