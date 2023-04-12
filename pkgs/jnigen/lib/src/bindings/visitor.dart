// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/elements.dart';

abstract class Visitor<T extends Element<T>, R> {
  const Visitor();

  R visit(T node);
}

abstract class TypeVisitor<R> {
  const TypeVisitor();

  R visitNonPrimitiveType(ReferredType node);
  R visitPrimitiveType(PrimitiveType node);
  R visitArrayType(ArrayType node) => visitNonPrimitiveType(node);
  R visitDeclaredType(DeclaredType node) => visitNonPrimitiveType(node);
  R visitTypeVar(TypeVar node) => visitNonPrimitiveType(node);
  R visitWildcard(Wildcard node) => visitNonPrimitiveType(node);
}

extension MultiVisitor<T extends Element<T>> on Iterable<Element<T>> {
  /// Accepts all lazily. Remember to call `.toList()` or similar methods!
  Iterable<R> accept<R>(Visitor<T, R> v) {
    return map((e) => e.accept(v));
  }
}

extension MultiTypeVisitor<T extends ReferredType> on Iterable<T> {
  /// Accepts all lazily. Remember to call `.toList()` or similar methods!
  Iterable<R> accept<R>(TypeVisitor<R> v) {
    return map((e) => e.accept(v));
  }
}

extension MultiTypeUsageVisitor on Iterable<TypeUsage> {
  /// Accepts all lazily. Remember to call `.toList()` or similar methods!
  Iterable<R> accept<R>(TypeVisitor<R> v) {
    return map((e) => e.type.accept(v));
  }
}
