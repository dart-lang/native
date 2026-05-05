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
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.boolean_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.sealed
public sealed class TestClass169<T extends Number>  {
  public boolean @Nullable [] setFoo(boolean @Nullable [] p1, int p2) throws Exception { return null; }
  public static interface Nested {}

  public static final class Sub<T extends Number> extends TestClass169<T> {}
}
