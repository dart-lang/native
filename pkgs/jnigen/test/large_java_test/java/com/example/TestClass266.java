// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.none
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.constructor
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.nestedCustom
public enum TestClass266  implements Runnable {
  VALUE1(null, 0), VALUE2(null, 0);
  public void run() {}
  private TestClass266(NestedCustom<String, String>.Nested<String>[] p1, int p2) {}
  public static record NestedRecord(int x) {}

}
