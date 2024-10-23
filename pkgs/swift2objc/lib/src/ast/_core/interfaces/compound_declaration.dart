// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../declarations/compounds/members/initializer_declaration.dart';
import '../../declarations/compounds/members/method_declaration.dart';
import '../../declarations/compounds/members/property_declaration.dart';
import 'declaration.dart';
import 'protocol_conformable.dart';
import 'type_parameterizable.dart';

/// An interface for the declaration of all compound Swift entities.
/// See `ClassDeclaration`, `StructDeclaration` and `ProtocolDeclaration`
/// for concrete implementations.
abstract interface class CompoundDeclaration
    implements Declaration, TypeParameterizable, ProtocolConformable {
  abstract List<PropertyDeclaration> properties;
  abstract List<MethodDeclaration> methods;
  abstract List<InitializerDeclaration> initializers;

  /// For handling nested classes
  abstract List<String> pathComponents;
}
