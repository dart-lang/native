// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.record
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customEnum
public class TestClass186<T, U>  implements DagA, DagD, DagE {
  public void run() {}
  public static <S> CustomEnum isFoo(CustomEnum p1) { return null; }
  public static record NestedRecord(int x) {}

}
