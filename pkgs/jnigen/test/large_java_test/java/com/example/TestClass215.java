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
// MemberModifier: MemberModifier.transient
// MemberName: MemberName.any
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.sealed
// TypeKind: TypeKind.typeParam
public sealed class TestClass215<T extends Number>  {
  public transient T myField;
  public class Nested {}

  public static final class Sub<T extends Number> extends TestClass215<T> {}
}
