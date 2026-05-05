// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.int_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass179<@Nullable T, @Nullable U>  {
  public static <@Nullable S extends Number> int @NotNull [] getFoo(int @NotNull [] p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
