// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.yes
// Member: Member.initializer
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.static_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.boolean_
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass281<@Nullable T, @Nullable U>  implements OtherInterface, BaseInterface {
  @Override
  public void otherInterfaceMethod() {}
  @Override
  public void baseMethod() {}
  static { }
  public static class Nested {}

}
