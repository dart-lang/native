// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.oneParam
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.volatile
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.int_
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass266<@NotNull T>  extends GenericParent<@NotNull String> {
  @Override
  public void genericParentMethod(String t) {}
  public volatile int myField;
  public enum NestedEnum { V1 }

}
