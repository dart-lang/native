// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.oneParam
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.record
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
// TypeKind: TypeKind.boolean_
public final class TestClass122<T>  implements Runnable, Cloneable {
  public void run() {}
  public synchronized <S, V> boolean[] getFoo(boolean[] p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
