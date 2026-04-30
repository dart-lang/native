// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.oneParam
// Inheritance: Inheritance.diamond
// IsArray: IsArray.yes
// Member: Member.constructor
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// NestedKind: NestedKind.record
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
// TypeKind: TypeKind.customInterface
public final class TestClass93<T>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public <S> TestClass93(CustomInterface<S>[] p1) {}
  public static record NestedRecord(int x) {}

}
