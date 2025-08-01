// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../_core/interfaces/enum_declaration.dart';
import '../../_core/interfaces/nestable_declaration.dart';
import '../../_core/interfaces/objc_annotatable.dart';
import '../../_core/shared/referred_type.dart';
import '../../ast_node.dart';
import '../compounds/protocol_declaration.dart';

/// Describes the declaration of a Swift enum with raw values.
class RawValueEnumDeclaration<T> extends AstNode
    implements EnumDeclaration, ObjCAnnotatable {
  @override
  String id;

  @override
  String name;

  @override
  covariant List<RawValueEnumCase<T>> cases;

  @override
  List<GenericType> typeParams;

  @override
  List<DeclaredType<ProtocolDeclaration>> conformedProtocols;

  @override
  bool hasObjCAnnotation;

  @override
  OuterNestableDeclaration? nestingParent;

  @override
  List<InnerNestableDeclaration> nestedDeclarations;

  ReferredType rawValueType;

  RawValueEnumDeclaration({
    required this.id,
    required this.name,
    required this.cases,
    required this.typeParams,
    required this.conformedProtocols,
    required this.hasObjCAnnotation,
    required this.rawValueType,
    this.nestingParent,
    this.nestedDeclarations = const [],
  });

  @override
  void visit(Visitation visitation) =>
      visitation.visitRawValueEnumDeclaration(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visitAll(cases);
    visitor.visitAll(typeParams);
    visitor.visitAll(conformedProtocols);
    visitor.visit(nestingParent);
    visitor.visitAll(nestedDeclarations);
    visitor.visit(rawValueType);
  }
}

/// Describes the declaration of a Swift enum case with a raw value of type `T`.
class RawValueEnumCase<T> extends AstNode implements EnumCase {
  @override
  String id;

  @override
  String name;

  T rawValue;

  RawValueEnumCase({
    required this.id,
    required this.name,
    required this.rawValue,
  });
}
