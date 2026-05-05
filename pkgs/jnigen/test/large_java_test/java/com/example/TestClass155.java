// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.twoParams
// Inheritance: Inheritance.none
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.string
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass155<T, U>  {
  public final <S extends Number> @NotNull String myMethod() { return null; }
  public enum NestedEnum { V1 }

}
