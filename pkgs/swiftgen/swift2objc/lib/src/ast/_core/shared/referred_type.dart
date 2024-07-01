// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/ast/_core/interfaces/objc_annotatable.dart';

import '../interfaces/declaration.dart';

/// Describes a type reference in declaration of Swift entities (e.g a method return type).
/// See `DeclaredType` and `GenericType` for concrete implementation.
sealed class ReferredType {
  final String id;
  abstract final bool isObjcRepresentable;

  const ReferredType({required this.id});
}

/// Describes a reference of a declared type (user-defined or built-in).
class DeclaredType<T extends Declaration> extends ReferredType {
  final T declaration;
  final List<ReferredType> typeParams;

  @override
  bool get isObjcRepresentable =>
      declaration is ObjCAnnotatable &&
      (declaration as ObjCAnnotatable).hasObjCAnnotation;

  const DeclaredType({
    required super.id,
    required this.declaration,
    this.typeParams = const [],
  });
}

/// Describes a reference of a generic type (e.g a method return type `T` within a generic class).
class GenericType extends ReferredType {
  final String name;

  @override
  bool get isObjcRepresentable => false;

  const GenericType({
    required this.name,
    required super.id,
  });
}
