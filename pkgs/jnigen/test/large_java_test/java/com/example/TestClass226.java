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
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.char_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass226<@Nullable T extends Number>  implements DagA, DagD, DagE {
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
  public final <@Nullable S, @Nullable V> char @NotNull [] getFoo(char @NotNull [] p1) { return null; }
  public static interface Nested {}

}
