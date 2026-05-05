// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.int_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass28<@NotNull T, @NotNull U>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public final <@NotNull S> int @Nullable [] myMethod() { return null; }
  public static record NestedRecord(int x) {}

}
