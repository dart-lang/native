// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/interfaces/parameterizable.dart';
import '../../_core/shared/parameter.dart';
import '../../_core/shared/referred_type.dart';
import '../compounds/protocol_declaration.dart';

/// Describes the declaration of a Swift enum with associated values.
class AssociatedValueEnumDeclaration implements EnumDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<AssociatedValueEnumCase> cases;

  @override
  List<GenericType> typeParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  AssociatedValueEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.typeParams,
    required this.conformedProtocols,
  });
}

/// Describes the declaration of a Swift enum case with associated values.
class AssociatedValueEnumCase implements EnumCase, Parameterizable {
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

/// Describes an associated value of an Swift enum case.
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
