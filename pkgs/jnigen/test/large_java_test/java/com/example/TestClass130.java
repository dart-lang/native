// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.none
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.any
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.sealed
// TypeKind: TypeKind.set
public sealed class TestClass130<T, U>  {
  public final Set<T> myMethod() { return null; }
  public static class Nested {}

  public static final class Sub<T, U> extends TestClass130<T, U> {}
}
