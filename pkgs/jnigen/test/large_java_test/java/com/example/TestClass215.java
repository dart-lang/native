// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.typeParam
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public abstract interface TestClass215<@Nullable T, @Nullable U>  extends DagA, DagD, DagE {
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
  <@Nullable S extends Number> @Nullable T getFoo(@Nullable T p1, int p2);
  public static class Nested {}

}
