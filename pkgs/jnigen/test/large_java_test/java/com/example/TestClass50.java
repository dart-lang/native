// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.oneParam
// Inheritance: Inheritance.extends_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.setFoo
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
// TypeKind: TypeKind.boolean_
public final class TestClass50<T>  extends Object {
  public void run() {}
  public synchronized <S, V> boolean setFoo(boolean p1, int p2) { return false; }
  public static record NestedRecord(int x) {}

}
