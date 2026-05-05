// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.diamond
// IsArray: IsArray.no
// Member: Member.constructor
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.long_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass202<@Nullable T, @Nullable U>  implements DiamondLeft, DiamondRight {
  @Override
  public void baseMethod() {}
  @Override
  public void leftMethod() {}
  @Override
  public void rightMethod() {}
  public <@Nullable S extends Number> TestClass202(long p1, int p2) {}
  public static interface Nested {}

}
