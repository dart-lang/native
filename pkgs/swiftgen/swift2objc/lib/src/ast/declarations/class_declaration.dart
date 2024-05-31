// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../_core/interfaces/compund_declaration.dart';
import '../_core/interfaces/objc_annotatable.dart';
import '../_core/shared/parameter.dart';
import '../_core/shared/referred_type.dart';
import 'protocol_declaration.dart';

class ClassDeclaration implements CompoundDeclaration, ObjcAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<ClassPropertyDeclaration> properties;

  @override
  covariant List<ClassMethodDeclaration> methods;

  @override
  List<ProtocolDeclaration> conformedProtocols;

  @override
  List<GenericType> genericParams;

  @override
  bool hasObjcAnnotation;

  ClassDeclaration? superClass;

  ClassDeclaration({
    required this.id,
    required this.name,
    required this.properties,
    required this.methods,
    required this.conformedProtocols,
    required this.genericParams,
    required this.hasObjcAnnotation,
    this.superClass,
  });
}

class ClassPropertyDeclaration
    implements CompoundPropertyDeclaration, ObjcAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  bool hasSetter;

  @override
  ReferredType type;

  @override
  bool hasObjcAnnotation;

  ClassPropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    required this.hasSetter,
    required this.hasObjcAnnotation,
  });
}

class ClassMethodDeclaration
    implements CompoundMethodDeclaration, ObjcAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  List<Parameter> params;

  @override
  List<GenericType> genericParams;

  @override
  ReferredType returnType;

  @override
  bool hasObjcAnnotation;

  ClassMethodDeclaration({
    required this.id,
    required this.name,
    required this.params,
    required this.genericParams,
    required this.returnType,
    required this.hasObjcAnnotation,
  });
}
