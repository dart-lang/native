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
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.char_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public abstract interface TestClass220<@NotNull T extends Number>  extends OtherInterface {
  @Override
  default void otherInterfaceMethod() {}
  char @NotNull [] isFoo();
  public class Nested {}

}
