// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.oneParam
// Inheritance: Inheritance.diamond
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.isFoo
// MemberType: MemberType.float_
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass144<T>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public synchronized <S extends Number> float isFoo(float p1, int p2) { return 0.0f; }
  public enum NestedEnum { V1 }

}
