// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.none
// Inheritance: Inheritance.implements_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.nestedCustom
public enum TestClass92  implements Runnable {
  VALUE1, VALUE2;
  public void run() {}
  public <S, V> NestedCustom<S, S>.Nested<S> isFoo(NestedCustom<S, S>.Nested<S> p1) throws Exception { return null; }
  public static interface Nested {}

}
