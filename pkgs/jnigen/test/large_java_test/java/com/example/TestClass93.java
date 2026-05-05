// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.extends_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.string
// NestedKind: NestedKind.none
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass93<@Nullable T, @Nullable U>  extends GrandParent {
  @Override
  public void grandParentMethod() {}
  public <@Nullable S> @Nullable String isFoo(@Nullable String p1, int p2) throws Exception { return null; }
}
