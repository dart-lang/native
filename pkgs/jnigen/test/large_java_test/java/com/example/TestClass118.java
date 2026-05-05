// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.oneParam
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.typeParam
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass118<@NotNull T>  extends GenericInterface {
  @Override
  default Object genericInterfaceMethod(Object t)  { return t; }
  @NotNull T myMethod(@NotNull T p1) throws Exception;
  public class Nested {}

}
