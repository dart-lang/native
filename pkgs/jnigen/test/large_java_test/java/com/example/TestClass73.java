// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.none
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.constructor
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.byte_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
public enum TestClass73  {
  VALUE1(null, 0), VALUE2(null, 0);
  private <@Nullable S> TestClass73(byte @Nullable [] p1, int p2) {}
  public static record NestedRecord(int x) {}

}
