// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.oneParam
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.typeParam
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass87<T>  extends DagA, DagD, DagE {
  @Override
  default void aMethod() {}
  @Override
  default void bMethod() {}
  @Override
  default void cMethod() {}
  @Override
  default void dMethod() {}
  @Override
  default void eMethod() {}
  <S extends Number> @NotNull T[] isFoo(@NotNull T[] p1, int p2) throws Exception;
  public static class Nested {}

}
