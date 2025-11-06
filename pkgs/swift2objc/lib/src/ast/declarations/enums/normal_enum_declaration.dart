// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../config.dart';
import '../../_core/interfaces/availability.dart';
import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import '../compounds/protocol_declaration.dart';

/// Describes the declaration of a basic Swift enum
/// (i.e with no raw values or associated values).
class NormalEnumDeclaration extends AstNode implements EnumDeclaration {
  @override
  String id;

  @override
  String name;

  @override
  InputConfig? source;

  @override
  List<AvailabilityInfo> availability;

  @override
  covariant List<NormalEnumCase> cases;

  @override
  List<GenericType> typeParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  OuterNestableDeclaration? nestingParent;

  @override
  List<InnerNestableDeclaration> nestedDeclarations;

  NormalEnumDeclaration({
    required this.id,
    required this.name,
    required this.source,
    required this.availability,
    required this.cases,
    required this.typeParams,
    required this.conformedProtocols,
    this.nestingParent,
    this.nestedDeclarations = const [],
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitNormalEnumDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(cases);
    visitor.visitAll(typeParams);
    visitor.visitAll(conformedProtocols);
    visitor.visit(nestingParent);
    visitor.visitAll(nestedDeclarations);
  }
}

/// Describes the declaration of a basic Swift enum case
/// (i.e with no raw values or associated values).
class NormalEnumCase extends AstNode implements EnumCase {
  @override
  String id;

  @override
  String name;

  @override
  InputConfig? source;

  @override
  List<AvailabilityInfo> availability;

  NormalEnumCase({
    required this.id,
    required this.name,
    required this.source,
    required this.availability,
  });
}
