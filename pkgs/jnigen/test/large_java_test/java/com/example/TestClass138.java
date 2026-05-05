// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.oneParam
// Inheritance: Inheritance.diamond
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.none
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.string
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass138<@Nullable T>  implements DiamondLeft, DiamondRight {
  @Override
  public void baseMethod() {}
  @Override
  public void leftMethod() {}
  @Override
  public void rightMethod() {}
  public <@Nullable S, @Nullable V> String getFoo(String p1, int p2) { return null; }
  public static interface Nested {}

}
