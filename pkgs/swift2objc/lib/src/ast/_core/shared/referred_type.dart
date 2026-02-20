// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast_node.dart';
import '../../declarations/typealias_declaration.dart';
import '../interfaces/declaration.dart';
import '../interfaces/nestable_declaration.dart';
import '../interfaces/objc_annotatable.dart';

/// Describes a type reference in declaration of Swift
/// entities (e.g a method return type).
/// See `DeclaredType` and `GenericType` for concrete implementation.
sealed class ReferredType extends AstNode {
  abstract final bool isObjCRepresentable;

  abstract final String swiftType;

  bool _sameAs(ReferredType other);

  const ReferredType();

  ReferredType get aliasedType;

  @override
  void visit(Visitation visitation) => visitation.visitReferredType(this);
}

extension ReferredTypeExt on ReferredType {
  bool sameAs(ReferredType other) => aliasedType._sameAs(other.aliasedType);
}

/// Describes a reference of a declared type (user-defined or built-in).
class DeclaredType<T extends Declaration> extends AstNode
    implements ReferredType {
  final String id;

  String get name {
    final decl = declaration;
    final parent = decl is InnerNestableDeclaration ? decl.nestingParent : null;
    final nesting = parent != null ? '${parent.name}.' : '';
    return '$nesting${declaration.name}';
  }

  final T declaration;
  final List<ReferredType> typeParams;

  @override
  bool get isObjCRepresentable => switch (declaration) {
    TypealiasDeclaration decl => decl.target.isObjCRepresentable,
    ObjCAnnotatable decl => decl.hasObjCAnnotation,
    _ => false,
  };

  @override
  String get swiftType => name;

  @override
  bool _sameAs(ReferredType other) => other is DeclaredType && other.id == id;

  @override
  ReferredType get aliasedType => switch (declaration) {
    TypealiasDeclaration decl => decl.target.aliasedType,
    _ => this,
  };

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
  bool _sameAs(ReferredType other) => other is GenericType && other.id == id;

  @override
  ReferredType get aliasedType => this;

  const GenericType({required this.id, required this.name});

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
  bool _sameAs(ReferredType other) =>
      other is OptionalType && child.sameAs(other.child);

  @override
  ReferredType get aliasedType => OptionalType(child.aliasedType);

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

/// Describes a reference to a Swift Tuple type (e.g., `(Int, String)`).
class TupleType extends AstNode implements ReferredType {
  final List<TupleElement> elements;

  @override
  bool get isObjCRepresentable => false;

  @override
  String get swiftType {
    final elementStrings = elements
        .map((e) {
          final label = e.label != null ? '${e.label}: ' : '';
          return '$label${e.type.swiftType}';
        })
        .join(', ');
    return '($elementStrings)';
  }

  @override
  bool _sameAs(ReferredType other) {
    if (other is! TupleType) return false;
    if (elements.length != other.elements.length) return false;
    for (var i = 0; i < elements.length; i++) {
      if (!elements[i].type.sameAs(other.elements[i].type)) return false;
      if (elements[i].label != other.elements[i].label) return false;
    }
    return true;
  }

  @override
  ReferredType get aliasedType =>
      TupleType(elements.map((e) => e.aliasedElement).toList());

  TupleType(this.elements);

  @override
  String toString() => swiftType;

  @override
  void visit(Visitation visitation) => visitation.visitTupleType(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    for (final element in elements) {
      visitor.visit(element.type);
    }
  }
}

class TupleElement {
  final String? label;
  final ReferredType type;

  TupleElement({this.label, required this.type});

  TupleElement get aliasedElement =>
      TupleElement(label: label, type: type.aliasedType);
}
