// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.oneParam
// Inheritance: Inheritance.extends_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.int_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass50<@NotNull T>  extends GrandParent {
  @Override
  public void grandParentMethod() {}
  public <@NotNull S extends Number> int myMethod() { return 0; }
  public static record NestedRecord(int x) {}

}
