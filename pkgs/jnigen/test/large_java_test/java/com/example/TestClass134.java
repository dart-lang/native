// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.long_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass134<@NotNull T, @NotNull U>  implements OtherInterface, BaseInterface {
  @Override
  public void otherInterfaceMethod() {}
  @Override
  public void baseMethod() {}
  public static <@NotNull S, @NotNull V> long @Nullable [] setFoo(long @Nullable [] p1) { return null; }
  public static interface Nested {}

}
