// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.none
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.long_
// NestedKind: NestedKind.none
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass52  implements DagA, DagD, DagE {
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
  public final <@Nullable S, @Nullable V> long @Nullable [] isFoo() { return null; }
}
