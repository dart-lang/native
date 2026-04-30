// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.none
// IsArray: IsArray.no
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// NestedKind: NestedKind.none
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.sealed
// TypeKind: TypeKind.double_
public sealed class TestClass146<T extends Number>  {
  public double myField;
  public static final class Sub<T extends Number> extends TestClass146<T> {}
}
