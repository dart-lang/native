// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.none
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.object
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass176<T extends Number>  extends GenericParent<String> {
  @Override
  public void genericParentMethod(String t) {}
  public <S extends Number> @NotNull Object getFoo() { return null; }
  public static interface Nested {}

}
