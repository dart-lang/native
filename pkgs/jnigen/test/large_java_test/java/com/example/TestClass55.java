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
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.customRecord
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public abstract class TestClass55<@NotNull T>  extends GenericParent<@NotNull String> {
  @Override
  public void genericParentMethod(String t) {}
  public abstract @Nullable CustomRecord<@NotNull T> isFoo(@Nullable CustomRecord<@NotNull T> p1, int p2);
  public class Nested {}

}
