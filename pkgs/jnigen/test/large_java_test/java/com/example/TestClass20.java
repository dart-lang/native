// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.none
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.native
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.nestedCustom
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass20  extends DagA, DagD, DagE {
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
  <@NotNull S> @Nullable NestedCustom<@NotNull S, @NotNull S>.Nested<@NotNull S> isFoo();
  public enum NestedEnum { V1 }

}
