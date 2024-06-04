// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/compund_declaration.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import 'protocol_declaration.dart';

/// Describes the declaration of a Swift struct.
class StructDeclaration implements CompoundDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<StructPropertyDeclaration> properties;

  @override
  covariant List<StructMethodDeclaration> methods;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  List<GenericType> genericParams;

  StructDeclaration({
    required this.id,
    required this.name,
    required this.properties,
    required this.methods,
    required this.conformedProtocols,
    required this.genericParams,
  });
}

/// Describes the declaration of a property in a Swift struct.
class StructPropertyDeclaration implements CompoundPropertyDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  bool hasSetter;

  @override
  ReferredType type;

  StructPropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    required this.hasSetter,
  });
}

/// Describes the declaration of a method in a Swift struct.
class StructMethodDeclaration implements CompoundMethodDeclaration {
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

  StructMethodDeclaration({
    required this.id,
    required this.name,
    required this.params,
    required this.genericParams,
    required this.returnType,
  });
}
