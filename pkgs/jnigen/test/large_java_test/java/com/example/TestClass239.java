// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass239<@NotNull T extends Number>  extends GenericParent<@NotNull String> {
  @Override
  public void genericParentMethod(String t) {}
  public <@NotNull S, @NotNull V> NestedCustom<@NotNull S, @NotNull S>.Nested<@NotNull S>[] myMethod(NestedCustom<@NotNull S, @NotNull S>.Nested<@NotNull S>[] p1, int p2) throws Exception { return null; }
  public class Nested {}

}
