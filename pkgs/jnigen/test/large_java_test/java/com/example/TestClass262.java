// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.native
// MemberName: MemberName.any
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
// TypeKind: TypeKind.list
public final class TestClass262<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public native <S extends Number> List<S>[] myMethod(List<S>[] p1);
  public enum NestedEnum { V1 }

}
