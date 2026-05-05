// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nonnull
// Generics: Generics.twoParams
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.native
// MemberName: MemberName.any
// MemberNullability: MemberNullability.none
// MemberType: MemberType.byte_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
public interface TestClass200<@NotNull T, @NotNull U>  extends OtherInterface, BaseInterface {
  @Override
  default void otherInterfaceMethod() {}
  @Override
  default void baseMethod() {}
  <@NotNull S> byte myMethod(byte p1);
  public class Nested {}

}
