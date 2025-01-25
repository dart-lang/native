// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import '../built_in/built_in_declaration.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';
import 'protocol_declaration.dart';

/// Describes the declaration of a Swift class.
class ClassDeclaration extends AstNode
    implements CompoundDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<PropertyDeclaration> properties;

  @override
  covariant List<MethodDeclaration> methods;

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
  PropertyDeclaration? wrappedInstance;

  /// An initializer that accepts an instance of the original being wrapped
  InitializerDeclaration? wrapperInitializer;

  @override
  List<InitializerDeclaration> initializers;

  @override
  NestableDeclaration? nestingParent;

  @override
  List<NestableDeclaration> nestedDeclarations;

  ClassDeclaration({
    required this.id,
    required this.name,
    this.properties = const [],
    this.methods = const [],
    this.nestingParent,
    this.nestedDeclarations = const [],
    this.conformedProtocols = const [],
    this.typeParams = const [],
    this.hasObjCAnnotation = false,
    this.superClass,
    this.isWrapper = false,
    this.wrappedInstance,
    this.wrapperInitializer,
    this.initializers = const [],
  }) : assert(superClass == null ||
            superClass.declaration is ClassDeclaration ||
            superClass.sameAs(objectType));

  @override
  void visit(Visitation visitation) => visitation.visitClassDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(properties);
    visitor.visitAll(methods);
    visitor.visitAll(conformedProtocols);
    visitor.visitAll(typeParams);
    visitor.visit(superClass);
    visitor.visit(wrappedInstance);
    visitor.visit(wrapperInitializer);
    visitor.visitAll(initializers);
    visitor.visit(nestingParent);
    visitor.visitAll(nestedDeclarations);
  }
}
