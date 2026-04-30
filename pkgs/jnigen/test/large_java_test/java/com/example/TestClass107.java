// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.extends_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.isFoo
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public abstract class TestClass107<T extends Number>  extends Object {
  public void run() {}
  public abstract <S extends Number> NestedCustom<S, S>.Nested<S>[] isFoo(NestedCustom<S, S>.Nested<S>[] p1, int p2);
  public enum NestedEnum { V1 }

}
