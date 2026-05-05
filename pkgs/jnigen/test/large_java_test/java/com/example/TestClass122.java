// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.memberTypeParam
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass122<@Nullable T extends Number>  extends GenericParent {
  @Override
  public void genericParentMethod(Object t) {}
  public <@Nullable S extends Number> @NotNull S setFoo(@NotNull S p1, int p2) throws Exception { return null; }
  public enum NestedEnum { V1 }

}
