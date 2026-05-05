// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.customInterface
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass104<@NotNull T extends Number>  implements DagA, DagD, DagE {
  @Override
  public void aMethod() {}
  @Override
  public void bMethod() {}
  @Override
  public void cMethod() {}
  @Override
  public void dMethod() {}
  @Override
  public void eMethod() {}
  public synchronized <@NotNull S> CustomInterface<@NotNull S> isFoo() { return null; }
  public static class Nested {}

}
