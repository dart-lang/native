// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.upperBound
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.none
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.customObject
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass242<@NotNull T extends Number>  implements OtherInterface, BaseInterface {
  @Override
  public void otherInterfaceMethod() {}
  @Override
  public void baseMethod() {}
  public <@NotNull S> @NotNull CustomObject<@NotNull S>[] setFoo(@NotNull CustomObject<@NotNull S>[] p1) { return null; }
  public static interface Nested {}

}
