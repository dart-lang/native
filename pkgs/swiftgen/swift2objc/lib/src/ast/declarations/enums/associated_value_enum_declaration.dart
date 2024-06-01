// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/interfaces/paramable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import '../compounds/protocol_declaration.dart';

class AssociatedValueEnumDeclaration implements EnumDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<AssociatedValueEnumCase> cases;

  @override
  List<GenericType> genericParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  AssociatedValueEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.genericParams,
    required this.conformedProtocols,
  });
}

class AssociatedValueEnumCase implements EnumCase, Paramable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<AssociatedValueParam> params;

  AssociatedValueEnumCase({
    required this.id,
    required this.name,
    required this.params,
  });
}

class AssociatedValueParam implements Parameter {
  @override
  String name;

  @override
  ReferredType type;

  @override
  covariant Null internalName = null;

  AssociatedValueParam({
    required this.name,
    required this.type,
  });
}
