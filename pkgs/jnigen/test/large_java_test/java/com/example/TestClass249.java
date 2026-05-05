// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.none
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.no
// Member: Member.constructor
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.string
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass249  implements OtherInterface, BaseInterface {
  @Override
  public void otherInterfaceMethod() {}
  @Override
  public void baseMethod() {}
  public <@Nullable S extends Number> TestClass249(@NotNull String p1) {}
  public enum NestedEnum { V1 }

}
