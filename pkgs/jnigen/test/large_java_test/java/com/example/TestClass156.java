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
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.char_
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass156<@NotNull T extends Number>  extends GrandParent {
  @Override
  public void grandParentMethod() {}
  public static <@NotNull S extends Number> char isFoo(char p1) { return ' '; }
  public enum NestedEnum { V1 }

}
