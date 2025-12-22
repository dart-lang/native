// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/elements.dart';

abstract class ElementVisitor<T extends Element<T>, R> {
  const ElementVisitor();

  R visit(T node);
}

mixin TopLevelVisitor<R> on ElementVisitor<Classes, R> {
  GenerationStage get stage;
}

abstract class TypeVisitor<R> {
  const TypeVisitor();

  R visitPrimitiveType(PrimitiveType node);
  R visitArrayType(ArrayType node);
  R visitDeclaredType(DeclaredType node);
  R visitTypeVar(TypeVar node);
  R visitWildcard(Wildcard node);
}

mixin DefaultNonPrimitive<R> on TypeVisitor<R> {
  R visitNonPrimitiveType(ReferredType node);
  @override
  R visitArrayType(ArrayType node) => visitNonPrimitiveType(node);
  @override
  R visitDeclaredType(DeclaredType node) => visitNonPrimitiveType(node);
  @override
  R visitTypeVar(TypeVar node) => visitNonPrimitiveType(node);
  @override
  R visitWildcard(Wildcard node) => visitNonPrimitiveType(node);
}

extension MultiVisitor<T extends Element<T>> on Iterable<Element<T>> {
  /// Accepts all lazily. Remember to call `.toList()` or similar methods!
  Iterable<R> accept<R>(ElementVisitor<T, R> v) {
    return map((e) => e.accept(v));
  }
}

extension MultiTypeUsageVisitor on Iterable<ReferredType> {
  /// Accepts all lazily. Remember to call `.toList()` or similar methods!
  Iterable<R> accept<R>(TypeVisitor<R> v) {
    return map((e) => e.accept(v));
  }
}
