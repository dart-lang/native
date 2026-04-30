// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.extends_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customObject
public class TestClass100<T, U>  extends Object {
  public void run() {}
  public final <S, V> CustomObject<S>[] getFoo() { return null; }
  public class Nested {}

}
