// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.oneParam
// Inheritance: Inheritance.complexDag
// IsArray: IsArray.no
// Member: Member.field
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.transient
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.customObject
// NestedKind: NestedKind.record
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
public class TestClass274<@Nullable T>  implements DagA, DagD, DagE {
  @Override
  public void aMethod() {}
  @Override
  public void bMethod() {}
  @Override
  public void cMethod() {}
  @Override
  public void dMethod() {}
  @Override
  public void eMethod() {}
  public transient CustomObject<@Nullable T> myField;
  public static record NestedRecord(int x) {}

}
