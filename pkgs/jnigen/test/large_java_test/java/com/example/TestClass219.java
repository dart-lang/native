// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.any
// MemberType: MemberType.customEnum
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.sealed
public sealed interface TestClass219<T extends Number>  {
  default CustomEnum[] myMethod(CustomEnum[] p1) { return null; }
  public static interface Nested {}

  public static final class Sub<T extends Number> implements TestClass219<T> {}
}
