// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.upperBound
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.boolean_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public abstract interface TestClass250<@NotNull T extends Number>  extends OtherInterface {
  @Override
  default void otherInterfaceMethod() {}
  <@NotNull S extends Number> boolean @NotNull [] myMethod(boolean @NotNull [] p1, int p2);
  public static interface Nested {}

}
