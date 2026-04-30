// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customInterface
public interface TestClass244<T extends Number>  extends Runnable, Cloneable {
  <S, V> CustomInterface<S> myMethod(CustomInterface<S> p1, int p2);
  public static interface Nested {}

}
