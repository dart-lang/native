// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.oneParam
// Inheritance: Inheritance.extends_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.any
// MemberNullability: MemberNullability.nullable
// MemberType: MemberType.byte_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass232<T>  extends OtherInterface {
  @Override
  default void otherInterfaceMethod() {}
  default byte @Nullable [] myMethod() { return null; }
  public static interface Nested {}

}
