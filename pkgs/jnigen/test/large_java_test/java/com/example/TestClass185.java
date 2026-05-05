// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.twoParams
// Inheritance: Inheritance.diamond
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.typeParam
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass185<T, U>  extends DiamondLeft, DiamondRight {
  @Override
  default void baseMethod() {}
  @Override
  default void leftMethod() {}
  @Override
  default void rightMethod() {}
  default <S, V> @NotNull T setFoo(@NotNull T p1, int p2) { return null; }
  public static interface Nested {}

}
