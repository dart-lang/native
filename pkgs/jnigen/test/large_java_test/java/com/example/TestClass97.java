// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.oneParam
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.native
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.object
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass97<@NotNull T>  extends GenericParent {
  @Override
  public void genericParentMethod(Object t) {}
  public native <@NotNull S extends Number> @Nullable Object[] getFoo(@Nullable Object[] p1, int p2);
  public static interface Nested {}

}
