// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public abstract class TestClass255<T extends Number>  extends GenericParent {
  @Override
  public void genericParentMethod(Object t) {}
  public abstract <S, V> @NotNull NestedCustom<S, S>.Nested<S>[] isFoo(@NotNull NestedCustom<S, S>.Nested<S>[] p1);
  public class Nested {}

}
