// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../interfaces/compound_declaration.dart';
import '../interfaces/declaration.dart';
import '../interfaces/objc_annotatable.dart';

/// Describes a type reference in declaration of Swift
/// entities (e.g a method return type).
/// See `DeclaredType` and `GenericType` for concrete implementation.
sealed class ReferredType {
  final String id;
  final String name;
  abstract final bool isObjCRepresentable;

  const ReferredType(this.name, {required this.id});
}

/// Describes a reference of a declared type (user-defined or built-in).
class DeclaredType<T extends Declaration> implements ReferredType {
  @override
  final String id;

  @override
  String get name {
    final decl = declaration;
    if (decl is CompoundDeclaration && decl.pathComponents.isNotEmpty) {
      return decl.pathComponents.join('.');
    }

    return declaration.name;
  }

  final T declaration;
  final List<ReferredType> typeParams;

  @override
  bool get isObjCRepresentable =>
      declaration is ObjCAnnotatable &&
      (declaration as ObjCAnnotatable).hasObjCAnnotation;

  const DeclaredType({
    required this.id,
    required this.declaration,
    this.typeParams = const [],
  });
}

/// Describes a reference of a generic type
/// (e.g a method return type `T` within a generic class).
class GenericType implements ReferredType {
  @override
  final String id;

  @override
  final String name;

  @override
  bool get isObjCRepresentable => false;

  const GenericType({
    required this.id,
    required this.name,
  });
}
