// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.none
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.int_
public enum TestClass48  implements Runnable {
  VALUE1, VALUE2;
  public void run() {}
  public final <S> int[] isFoo() { return null; }
  public static record NestedRecord(int x) {}

}
