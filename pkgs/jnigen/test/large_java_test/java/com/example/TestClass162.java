// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.int_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass162<@Nullable T extends Number>  extends GenericInterface {
  @Override
  default Object genericInterfaceMethod(Object t)  { return t; }
  static int @Nullable [] setFoo() { return null; }
  public static record NestedRecord(int x) {}

}
