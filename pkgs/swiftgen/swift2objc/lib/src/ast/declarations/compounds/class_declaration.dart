// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swift2objc/src/ast/declarations/built_in/built_in_declaration.dart';

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

  /// Super class can only be a class declaration or NSObject built-in declaration
  DeclaredType<Declaration>? superClass;

  /// If this class is a wrapper for another entity (class, struct, etc)
  bool isWrapper;

  /// An instance of the original entity that this class is wraping
  ClassPropertyDeclaration? wrappedInstance;

  ClassDeclaration({
    required this.id,
    required this.name,
    this.properties = const [],
    this.methods = const [],
    this.conformedProtocols = const [],
    this.typeParams = const [],
    this.hasObjCAnnotation = false,
    this.superClass,
    this.isWrapper = false,
    this.wrappedInstance,
  }) : assert(superClass == null ||
            superClass.declaration is ClassDeclaration ||
            superClass.declaration == BuiltInDeclarations.NSObject);
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

  List<String> statements;

  ClassMethodDeclaration({
    required this.id,
    required this.name,
    required this.returnType,
    required this.params,
    this.typeParams = const [],
    this.hasObjCAnnotation = false,
    this.statements = const [],
  });
}
