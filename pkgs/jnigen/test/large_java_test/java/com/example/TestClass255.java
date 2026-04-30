// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.double_
public interface TestClass255<T extends Number>  extends DagA, DagD, DagE {
  default <S, V> double getFoo(double p1) { return 0.0; }
  public static interface Nested {}

}
