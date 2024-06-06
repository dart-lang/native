// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../interfaces/declaration.dart';

/// Describes a type regerence in declaration of Swift entities (e.g a method return type).
/// See `DeclaredType` and `GenericType` for concrete implementation.
abstract class ReferredType {
  String id;

  ReferredType({required this.id});
}

class DeclaredType<T extends Declaration> extends ReferredType {
  T declaration;
  List<ReferredType> typeParams;
  
  DeclaredType({
    required super.id,
    required this.declaration,
    required this.typeParams,
  });
}

class GenericType extends ReferredType {
  String name;

  GenericType({
    required this.name,
    required super.id,
  });
}
