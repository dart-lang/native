// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.diamond
// IsArray: IsArray.yes
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.volatile
// MemberName: MemberName.any
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass258<T extends Number>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public volatile NestedCustom<T, T>.Nested<T>[] myField;
  public static interface Nested {}

}
