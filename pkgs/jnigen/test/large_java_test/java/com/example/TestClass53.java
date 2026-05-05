// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;
import org.jetbrains.annotations.Nullable;
import org.jetbrains.annotations.NotNull;

// GenericNullability: GenericNullability.nullable
// Generics: Generics.twoParams
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.final_
// MemberName: MemberName.isFoo
// MemberNullability: MemberNullability.nonnull
// MemberType: MemberType.float_
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.record
// TopLevelModifier: TopLevelModifier.none
public record TestClass53<@Nullable T, @Nullable U>(float @NotNull [] field)  {
}
