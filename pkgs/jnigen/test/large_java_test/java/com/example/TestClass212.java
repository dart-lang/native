// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.string
public interface TestClass212<T extends Number>  extends DagA, DagD, DagE {
  static String isFoo(String p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
