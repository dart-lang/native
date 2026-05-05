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
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.list
// NestedKind: NestedKind.none
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass71<@Nullable T extends Number>  extends OtherInterface {
  @Override
  default void otherInterfaceMethod() {}
  default <@Nullable S, @Nullable V> List<@Nullable S>[] myMethod(List<@Nullable S>[] p1) { return null; }
}
