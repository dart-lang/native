// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.upperBound
// Inheritance: Inheritance.extends_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.double_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public abstract class TestClass187<@NotNull T extends Number>  extends GrandParent {
  @Override
  public void grandParentMethod() {}
  public abstract <@NotNull S extends Number> double setFoo(double p1);
  public static record NestedRecord(int x) {}

}
