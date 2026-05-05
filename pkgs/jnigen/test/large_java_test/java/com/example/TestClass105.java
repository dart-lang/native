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
// Member: Member.constructor
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.object
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass105<@NotNull T extends Number>  implements OtherInterface, BaseInterface {
  @Override
  public void otherInterfaceMethod() {}
  @Override
  public void baseMethod() {}
  public TestClass105(@NotNull Object[] p1) {}
  public enum NestedEnum { V1 }

}
