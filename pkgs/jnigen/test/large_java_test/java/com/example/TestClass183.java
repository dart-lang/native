// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.boolean_
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass183<@Nullable T, @Nullable U>  extends GenericParent<@Nullable String> {
  @Override
  public void genericParentMethod(String t) {}
  public <@Nullable S extends Number> boolean getFoo(boolean p1, int p2) throws Exception { return false; }
  public enum NestedEnum { V1 }

}
