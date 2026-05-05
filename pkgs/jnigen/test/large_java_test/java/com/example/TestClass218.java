// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.customEnum
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass218<@NotNull T, @NotNull U>  extends GenericInterface {
  @Override
  default Object genericInterfaceMethod(Object t)  { return t; }
  default <@NotNull S, @NotNull V> CustomEnum[] isFoo(CustomEnum[] p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
