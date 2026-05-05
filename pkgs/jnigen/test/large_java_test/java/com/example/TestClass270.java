// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.oneParam
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.none
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.double_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass270<T>  extends GenericInterface<String> {
  @Override
  default String genericInterfaceMethod(String t)  { return t; }
  double myField = 0.0;
  public class Nested {}

}
