// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.customInterface
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass133<T extends Number>  extends GenericInterface {
  @Override
  default Object genericInterfaceMethod(Object t)  { return t; }
  <S> CustomInterface<S> myMethod(CustomInterface<S> p1) throws Exception;
  public static interface Nested {}

}
