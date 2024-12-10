// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../code_generator.dart';
import '../visitor/ast.dart';

import 'writer.dart';

/// Represents a FutureOr<T>.
class FutureOrType extends Type {
  final Type child;

  FutureOrType(this.child);

  @override
  String getCType(Writer w) => 'FutureOr<${child.getCType(w)}>';

  @override
  String getFfiDartType(Writer w) => 'FutureOr<${child.getFfiDartType(w)}>';

  @override
  String getDartType(Writer w) => 'FutureOr<${child.getDartType(w)}>';

  @override
  bool get sameFfiDartAndCType => child.sameFfiDartAndCType;

  @override
  String toString() => 'FutureOr<$child>';

  @override
  String cacheKey() => 'FutureOr<${child.cacheKey()}>';

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(child);
  }

  @override
  bool isSupertypeOf(Type other) {
    other = other.typealiasType;
    if (other is FutureOrType) {
      return child.isSupertypeOf(other.child);
    }
    return false;
  }
}
