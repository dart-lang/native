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
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.customEnum
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass267<@Nullable T>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  public @Nullable CustomEnum[] myField;
  public enum NestedEnum { V1 }

}
