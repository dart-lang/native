// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.implements_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.double_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass157<@Nullable T, @Nullable U>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public synchronized <@Nullable S, @Nullable V> double getFoo(double p1, int p2) { return 0.0; }
  public static interface Nested {}

}
