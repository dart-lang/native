// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.oneParam
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.short_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass92<@Nullable T>  extends OtherInterface {
  @Override
  default void otherInterfaceMethod() {}
  default <@Nullable S> short [] isFoo(short [] p1) { return null; }
  public static interface Nested {}

}
