// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/shared/referred_type.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';

/// Describes the declaration of a Swift protocol.
class ProtocolDeclaration implements CompoundDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<PropertyDeclaration> properties;

  @override
  covariant List<MethodDeclaration> methods;

  /// Only present if indicated with `@objc`
  @override
  List<PropertyDeclaration> optionalProperties;

  /// Only present if indicated with `@objc`
  @override
  List<MethodDeclaration> optionalMethods;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  bool hasObjCAnnotation;

  @override
  List<GenericType> typeParams;

  @override
  List<InitializerDeclaration> initializers;

  @override
  NestableDeclaration? nestingParent;

  @override
  List<NestableDeclaration> nestedDeclarations;

  ProtocolDeclaration({
    required this.id,
    required this.name,
    required this.properties,
    required this.methods,
    required this.initializers,
    required this.conformedProtocols,
    required this.typeParams,
    this.hasObjCAnnotation = false,
    this.nestingParent,
    this.nestedDeclarations = const [],
    this.optionalMethods = const [],
    this.optionalProperties = const [],
  });
}
