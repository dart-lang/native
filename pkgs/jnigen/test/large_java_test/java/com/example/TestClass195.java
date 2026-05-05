// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.upperBound
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.int_
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public abstract class TestClass195<T extends Number>  {
  public abstract <S, V> int @Nullable [] setFoo(int @Nullable [] p1, int p2);
  public static class Nested {}

}
