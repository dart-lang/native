// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.oneParam
// Inheritance: Inheritance.diamond
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.short_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass123<@Nullable T>  extends DiamondLeft, DiamondRight {
  @Override
  default void baseMethod() {}
  @Override
  default void leftMethod() {}
  @Override
  default void rightMethod() {}
  <@Nullable S> short @Nullable [] getFoo() throws Exception;
  public class Nested {}

}
