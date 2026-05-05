// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.customEnum
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass170<@NotNull T, @NotNull U>  extends GenericParent<@NotNull String> {
  @Override
  public void genericParentMethod(String t) {}
  public synchronized <@NotNull S extends Number> @Nullable CustomEnum myMethod(@Nullable CustomEnum p1, int p2) { return null; }
  public static interface Nested {}

}
