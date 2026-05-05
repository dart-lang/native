// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.none
// IsArray: IsArray.no
// Member: Member.initializer
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.long_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.sealed
public sealed class TestClass106<@NotNull T, @NotNull U>  {
  { }
  public static interface Nested {}

  public static final class Sub<@NotNull T, @NotNull U> extends TestClass106<T, U> {}
}
