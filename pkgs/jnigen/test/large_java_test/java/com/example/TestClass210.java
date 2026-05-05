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
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.native
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.customRecord
// NestedKind: NestedKind.none
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass210<@Nullable T extends Number>  extends DiamondLeft, DiamondRight {
  @Override
  default void baseMethod() {}
  @Override
  default void leftMethod() {}
  @Override
  default void rightMethod() {}
  <@Nullable S, @Nullable V> @NotNull CustomRecord<@Nullable S>[] setFoo(@NotNull CustomRecord<@Nullable S>[] p1, int p2);
}
