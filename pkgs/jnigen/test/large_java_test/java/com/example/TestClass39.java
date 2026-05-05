// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.none
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.long_
public enum TestClass39  implements OtherInterface {
  VALUE1, VALUE2;
  @Override
  public void otherInterfaceMethod() {}
  public final <S, V> long[] isFoo(long[] p1, int p2) { return null; }
  public static interface Nested {}

}
