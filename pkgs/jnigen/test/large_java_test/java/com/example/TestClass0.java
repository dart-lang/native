// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.none
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.float_
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass0<@Nullable T, @Nullable U>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public <@Nullable S> float [] setFoo(float [] p1) { return null; }
  public static class Nested {}

}
