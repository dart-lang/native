// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.setFoo
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.boolean_
public abstract interface TestClass192<T, U>  extends List {
  <S, V> boolean[] setFoo(boolean[] p1);
  public enum NestedEnum { V1 }

}
