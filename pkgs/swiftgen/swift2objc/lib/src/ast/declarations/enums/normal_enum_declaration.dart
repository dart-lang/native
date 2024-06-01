// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/shared/referred_type.dart';
import '../compounds/protocol_declaration.dart';

class NormalEnumDeclaration implements EnumDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<NormalEnumCase> cases;

  @override
  List<GenericType> genericParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  NormalEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.genericParams,
    required this.conformedProtocols,
  });

}

class NormalEnumCase implements EnumCase {
  @override
  String id;

  @override
  String name;

  NormalEnumCase({
    required this.id,
    required this.name,
  });
}
