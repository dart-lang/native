// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.transient
// MemberName: MemberName.any
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.sealed
// TypeKind: TypeKind.long_
public sealed class TestClass150<T extends Number>  {
  public transient long[] myField;
  public static record NestedRecord(int x) {}

  public static final class Sub<T extends Number> extends TestClass150<T> {}
}
