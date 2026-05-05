// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.set
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass69<T extends Number>  extends GenericInterface<String> {
  @Override
  default String genericInterfaceMethod(String t)  { return t; }
  default <S> Set<S> myMethod(Set<S> p1, int p2) { return null; }
  public static class Nested {}

}
