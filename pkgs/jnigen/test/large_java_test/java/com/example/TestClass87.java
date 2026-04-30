// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.none
// IsArray: IsArray.no
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.any
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.sealed
// TypeKind: TypeKind.int_
public sealed interface TestClass87<T, U>  {
  static int myField = 0;
  public static record NestedRecord(int x) {}

  public static final class Sub<T, U> implements TestClass87<T, U> {}
}
