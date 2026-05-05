// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.none
// Inheritance: Inheritance.none
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.none
// MemberType: MemberType.string
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.enum_
// TopLevelModifier: TopLevelModifier.none
public enum TestClass231  {
  VALUE1, VALUE2;
  public synchronized <@Nullable S, @Nullable V> String isFoo(String p1) { return null; }
  public class Nested {}

}
