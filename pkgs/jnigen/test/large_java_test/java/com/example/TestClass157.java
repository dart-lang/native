// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.nestedCustom
public abstract class TestClass157<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public abstract <S, V> NestedCustom<S, S>.Nested<S>[] isFoo();
  public static class Nested {}

}
