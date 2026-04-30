// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.yes
// Member: Member.constructor
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
// TypeKind: TypeKind.short_
public final class TestClass9<T, U>  implements Runnable, Cloneable {
  public void run() {}
  public <S extends Number> TestClass9(short[] p1) {}
  public static class Nested {}

}
