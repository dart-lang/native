// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.none
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass46  extends GenericInterface<@Nullable String> {
  @Override
  default String genericInterfaceMethod(String t)  { return t; }
  default @Nullable NestedCustom<@Nullable String, @Nullable String>.Nested<@Nullable String>[] getFoo(@Nullable NestedCustom<@Nullable String, @Nullable String>.Nested<@Nullable String>[] p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
