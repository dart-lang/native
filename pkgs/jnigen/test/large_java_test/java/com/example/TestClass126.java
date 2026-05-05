// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.oneParam
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.native
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.object
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass126<@NotNull T>  extends GenericParent<@NotNull String> {
  @Override
  public void genericParentMethod(String t) {}
  public native @NotNull Object[] isFoo(@NotNull Object[] p1);
  public static interface Nested {}

}
