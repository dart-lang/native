// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../_core/interfaces/compund_declaration.dart';
import '../_core/shared/parameter.dart';
import '../_core/shared/referred_type.dart';

class ProtocolDeclaration implements CompoundDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<ProtocolPropertyDeclaration> properties;

  @override
  covariant List<ProtocolMethodDeclaration> methods;

  @override
  List<ProtocolDeclaration> conformedProtocols;

  @override
  List<GenericType> genericParams;

  ProtocolDeclaration({
    required this.id,
    required this.name,
    required this.properties,
    required this.methods,
    required this.conformedProtocols,
    required this.genericParams,
  });
}

class ProtocolPropertyDeclaration implements CompoundPropertyDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  bool hasSetter;

  @override
  ReferredType type;

  ProtocolPropertyDeclaration({
    required this.id,
    required this.name,
    required this.type,
    required this.hasSetter,
  });
}

class ProtocolMethodDeclaration implements CompoundMethodDeclaration {
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

  ProtocolMethodDeclaration({
    required this.id,
    required this.name,
    required this.params,
    required this.genericParams,
    required this.returnType,
  });
}
