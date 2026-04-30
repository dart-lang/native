// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.diamond
// IsArray: IsArray.yes
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.volatile
// MemberName: MemberName.any
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.char_
public class TestClass111<T, U>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public volatile char[] myField;
  public static record NestedRecord(int x) {}

}
