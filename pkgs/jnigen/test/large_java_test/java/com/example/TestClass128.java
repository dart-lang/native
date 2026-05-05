// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.upperBound
// Inheritance: Inheritance.diamond
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.customInterface
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass128<@Nullable T extends Number>  implements DiamondLeft, DiamondRight {
  @Override
  public void baseMethod() {}
  @Override
  public void leftMethod() {}
  @Override
  public void rightMethod() {}
  public synchronized @NotNull CustomInterface<@Nullable T> getFoo(@NotNull CustomInterface<@Nullable T> p1) { return null; }
  public static class Nested {}

}
