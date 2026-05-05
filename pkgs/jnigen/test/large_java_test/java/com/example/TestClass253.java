// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.diamond
// IsArray: IsArray.no
// Member: Member.constructor
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.customRecord
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass253<@NotNull T, @NotNull U>  implements DiamondLeft, DiamondRight {
  @Override
  public void baseMethod() {}
  @Override
  public void leftMethod() {}
  @Override
  public void rightMethod() {}
  public <@NotNull S, @NotNull V> TestClass253() {}
  public static record NestedRecord(int x) {}

}
