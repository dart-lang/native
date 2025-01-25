// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast_node.dart';
import '../interfaces/declaration.dart';
import '../interfaces/nestable_declaration.dart';
import '../interfaces/objc_annotatable.dart';

/// Describes a type reference in declaration of Swift
/// entities (e.g a method return type).
/// See `DeclaredType` and `GenericType` for concrete implementation.
sealed class ReferredType extends AstNode {
  abstract final bool isObjCRepresentable;

  abstract final String swiftType;

  bool sameAs(ReferredType other);

  const ReferredType();

  @override
  void visit(Visitation visitation) => visitation.visitReferredType(this);
}

/// Describes a reference of a declared type (user-defined or built-in).
class DeclaredType<T extends Declaration> extends AstNode
    implements ReferredType {
  final String id;

  String get name {
    final decl = declaration;
    final parent = decl is NestableDeclaration ? decl.nestingParent : null;
    final nesting = parent != null ? '${parent.name}.' : '';
    return '$nesting${declaration.name}';
  }

  final T declaration;
  final List<ReferredType> typeParams;

  @override
  bool get isObjCRepresentable =>
      declaration is ObjCAnnotatable &&
      (declaration as ObjCAnnotatable).hasObjCAnnotation;

  @override
  String get swiftType => name;

  @override
  bool sameAs(ReferredType other) => other is DeclaredType && other.id == id;

  const DeclaredType({
    required this.id,
    required this.declaration,
    this.typeParams = const [],
  });

  @override
  String toString() => name;

  @override
  void visit(Visitation visitation) => visitation.visitDeclaredType(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(declaration);
    visitor.visitAll(typeParams);
  }
}

/// Describes a reference of a generic type
/// (e.g a method return type `T` within a generic class).
class GenericType extends AstNode implements ReferredType {
  final String id;

  final String name;

  @override
  bool get isObjCRepresentable => false;

  @override
  String get swiftType => name;

  @override
  bool sameAs(ReferredType other) => other is GenericType && other.id == id;

  const GenericType({
    required this.id,
    required this.name,
  });

  @override
  String toString() => name;

  @override
  void visit(Visitation visitation) => visitation.visitGenericType(this);
}

/// An optional type, like Dart's nullable types. Eg `String?`.
class OptionalType extends AstNode implements ReferredType {
  final ReferredType child;

  @override
  bool get isObjCRepresentable => child.isObjCRepresentable;

  @override
  String get swiftType => '$child?';

  @override
  bool sameAs(ReferredType other) =>
      other is OptionalType && child.sameAs(other.child);

  OptionalType(this.child);

  @override
  String toString() => swiftType;

  @override
  void visit(Visitation visitation) => visitation.visitOptionalType(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(child);
  }
}
