// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.native
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.short_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass160<@Nullable T, @Nullable U>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public native short @NotNull [] getFoo(short @NotNull [] p1);
  public class Nested {}

}
