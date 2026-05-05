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
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.int_
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass132<@NotNull T extends Number>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public static <@NotNull S> int @Nullable [] setFoo() { return null; }
  public static record NestedRecord(int x) {}

}
