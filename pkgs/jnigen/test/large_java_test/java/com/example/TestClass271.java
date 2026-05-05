// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.none
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.customInterface
// NestedKind: NestedKind.staticClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
public enum TestClass271  implements OtherInterface {
  VALUE1, VALUE2;
  @Override
  public void otherInterfaceMethod() {}
  public @NotNull CustomInterface<@NotNull String>[] myField;
  public static class Nested {}

}
