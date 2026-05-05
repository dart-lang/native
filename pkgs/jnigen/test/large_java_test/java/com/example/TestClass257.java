// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.upperBound
// Inheritance: Inheritance.diamond
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.native
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.customObject
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass257<@Nullable T extends Number>  implements DiamondLeft, DiamondRight {
  @Override
  public void baseMethod() {}
  @Override
  public void leftMethod() {}
  @Override
  public void rightMethod() {}
  public native <@Nullable S, @Nullable V> CustomObject<@Nullable S>[] isFoo(CustomObject<@Nullable S>[] p1, int p2);
  public class Nested {}

}
