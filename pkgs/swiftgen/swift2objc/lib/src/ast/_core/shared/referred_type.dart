// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../interfaces/declaration.dart';

abstract class ReferredType {
  String id;

  ReferredType({required this.id});
}

class DeclaredType<T extends Declaration> extends ReferredType {
  T declaration;
  List<ReferredType> genericParams;

  DeclaredType({
    required super.id,
    required this.declaration,
    required this.genericParams,
  });
}

class GenericType extends ReferredType {
  String name;

  GenericType({
    required this.name,
    required super.id,
  });
}
