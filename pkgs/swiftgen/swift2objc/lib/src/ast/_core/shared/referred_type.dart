// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../interfaces/declaration.dart';

/// Describes a type reference in declaration of Swift entities (e.g a method return type).
/// See `DeclaredType` and `GenericType` for concrete implementation.
abstract class ReferredType {
  String id;

  ReferredType({required this.id});
}

/// Describes a reference of a declared type (user-defined or built-in).
class DeclaredType<T extends Declaration> extends ReferredType {
  T declaration;
  List<ReferredType> typeParams;

  DeclaredType({
    required super.id,
    required this.declaration,
    List<ReferredType>? typeParams,
  }): this.typeParams = typeParams ?? [];
}

/// Describes a reference of a generic type (e.g a method return type `T` within a generic class).
class GenericType extends ReferredType {
  String name;

  GenericType({
    required this.name,
    required super.id,
  });
}

class PlaceholderType extends ReferredType {
  static final instance = PlaceholderType._();
  PlaceholderType._() : super(id: "placeholder");
}
