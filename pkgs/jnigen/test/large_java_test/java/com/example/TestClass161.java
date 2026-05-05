// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.none
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.map
// NestedKind: NestedKind.none
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
public enum TestClass161  {
  VALUE1, VALUE2;
  public @Nullable Map<@Nullable String, @Nullable String>[] isFoo(@Nullable Map<@Nullable String, @Nullable String>[] p1) { return null; }
}
