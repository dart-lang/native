// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/interfaces/parameterizable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import '../built_in/built_in_declaration.dart';
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

  /// Super class can only be a class declaration or
  /// NSObject built-in declaration
  DeclaredType<Declaration>? superClass;

  /// If this class is a wrapper for another entity (class, struct, etc)
  bool isWrapper;

  /// An instance of the original entity that this class is wraping
  ClassPropertyDeclaration? wrappedInstance;

  ClassInitializer? initializer;

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
    this.initializer,
  }) : assert(superClass == null ||
            superClass.declaration is ClassDeclaration ||
            superClass.declaration == BuiltInDeclarations.swiftNSObject);
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

  List<String> getterStatements;
  List<String> setterStatements;

  ClassPropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    this.hasSetter = false,
    this.hasObjCAnnotation = false,
    this.getterStatements = const [],
    this.setterStatements = const [],
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
  ReferredType? returnType;

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

class ClassInitializer implements Parameterizable {
  @override
  List<Parameter> params;

  List<String> statements;

  ClassInitializer({
    required this.params,
    required this.statements,
  });
}
