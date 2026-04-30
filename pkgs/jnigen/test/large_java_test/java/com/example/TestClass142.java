// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.implements_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.isFoo
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass142<T extends Number>  implements Runnable {
  public void run() {}
  public NestedCustom<T, T>.Nested<T> isFoo(NestedCustom<T, T>.Nested<T> p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
