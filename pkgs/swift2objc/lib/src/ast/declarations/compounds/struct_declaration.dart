// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/shared/referred_type.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';
import 'protocol_declaration.dart';

/// Describes the declaration of a Swift struct.
class StructDeclaration implements CompoundDeclaration {
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
  List<InitializerDeclaration> initializers;

  @override
  NestableDeclaration? nestingParent;

  @override
  List<NestableDeclaration> nestedDeclarations;

  StructDeclaration({
    required this.id,
    required this.name,
    this.properties = const [],
    this.methods = const [],
    this.initializers = const [],
    this.conformedProtocols = const [],
    this.typeParams = const [],
    this.nestingParent,
    this.nestedDeclarations = const [],
  });
}
