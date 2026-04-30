// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.none
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.short_
public abstract interface TestClass241<T extends Number>  extends DagA, DagD, DagE {
  short[] isFoo(short[] p1, int p2);
}
