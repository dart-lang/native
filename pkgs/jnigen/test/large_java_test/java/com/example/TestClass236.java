// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.transient
// MemberName: MemberName.any
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.nestedCustom
public class TestClass236<T extends Number>  implements Runnable {
  public void run() {}
  public transient NestedCustom<T, T>.Nested<T>[] myField;
  public static class Nested {}

}
