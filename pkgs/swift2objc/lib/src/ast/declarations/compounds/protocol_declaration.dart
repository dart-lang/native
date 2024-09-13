// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compound_declaration.dart';
import '../../_core/shared/referred_type.dart';
import 'members/initializer_declaration.dart';
import 'members/method_declaration.dart';
import 'members/property_declaration.dart';

/// Describes the declaration of a Swift protocol.
class ProtocolDeclaration implements CompoundDeclaration {
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

  ProtocolDeclaration({
    required this.id,
    required this.name,
    required this.properties,
    required this.methods,
    required this.initializers,
    required this.conformedProtocols,
    required this.typeParams,
  });
}
