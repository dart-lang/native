// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.upperBound
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.float_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass217<@Nullable T extends Number>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public static <@Nullable S, @Nullable V> float [] myMethod() { return null; }
  public class Nested {}

}
