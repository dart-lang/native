// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.none
// Generics: Generics.upperBound
// Inheritance: Inheritance.implements_
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.setFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.short_
// NestedKind: NestedKind.innerClass
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.record
// TopLevelModifier: TopLevelModifier.none
public record TestClass139<T extends Number>(short @NotNull [] field)  implements OtherInterface {
  @Override
  public void otherInterfaceMethod() {}
}
