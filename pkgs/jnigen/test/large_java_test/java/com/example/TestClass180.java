// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.getFoo
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.customRecord
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.final_
public final class TestClass180<T, U>  extends GenericParent {
  @Override
  public void genericParentMethod(Object t) {}
  public <S> @Nullable CustomRecord<S>[] getFoo(@Nullable CustomRecord<S>[] p1) throws Exception { return null; }
  public class Nested {}

}
