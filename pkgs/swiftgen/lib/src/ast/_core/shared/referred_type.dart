// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../interfaces/declaration.dart';

abstract class ReferredType {
  String id;

  ReferredType({required this.id});
}

class DeclaredType extends ReferredType {
  Declaration declatation;
  List<ReferredType> genericParams;

  DeclaredType({
    required super.id,
    required this.declatation,
    required this.genericParams,
  });
}

class GenericType extends ReferredType {
  GenericType({required super.id});
}
