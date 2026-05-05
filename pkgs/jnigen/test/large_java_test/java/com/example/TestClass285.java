// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.upperBound
// Inheritance: Inheritance.implements_
// IsArray: IsArray.no
// Member: Member.initializer
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.map
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass285<@NotNull T extends Number>  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
  { }
  public enum NestedEnum { V1 }

}
