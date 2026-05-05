// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.none
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.object
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass221<@NotNull T, @NotNull U>  extends GenericParent<@NotNull String> {
  @Override
  public void genericParentMethod(String t) {}
  public <@NotNull S> Object[] getFoo() { return null; }
  public enum NestedEnum { V1 }

}
