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
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass152<@Nullable T extends Number>  extends DiamondLeft, DiamondRight {
  @Override
  default void baseMethod() {}
  @Override
  default void leftMethod() {}
  @Override
  default void rightMethod() {}
  default <@Nullable S> @Nullable NestedCustom<@Nullable S, @Nullable S>.Nested<@Nullable S> getFoo(@Nullable NestedCustom<@Nullable S, @Nullable S>.Nested<@Nullable S> p1) { return null; }
  public class Nested {}

}
