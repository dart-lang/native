// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.upperBound
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.int_
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass4<@Nullable T extends Number>  extends DagA, DagD, DagE {
  @Override
  default void aMethod() {}
  @Override
  default void bMethod() {}
  @Override
  default void cMethod() {}
  @Override
  default void dMethod() {}
  @Override
  default void eMethod() {}
  static int @NotNull [] setFoo(int @NotNull [] p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
