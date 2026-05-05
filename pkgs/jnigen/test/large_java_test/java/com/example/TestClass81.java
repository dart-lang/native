// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.none
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.object
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass81  extends DagA, DagD, DagE {
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
  default <@Nullable S extends Number> @Nullable Object getFoo(@Nullable Object p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
