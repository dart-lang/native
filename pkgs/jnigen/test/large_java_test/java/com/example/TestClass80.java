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
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customEnum
public class TestClass80<T extends Number>  extends Object {
  public void run() {}
  public static <S extends Number> CustomEnum[] getFoo(CustomEnum[] p1) { return null; }
  public enum NestedEnum { V1 }

}
