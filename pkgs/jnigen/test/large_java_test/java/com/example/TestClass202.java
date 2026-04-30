// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.extendsGenericUnspecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.isFoo
// NestedKind: NestedKind.interface
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.byte_
public interface TestClass202<T, U>  extends List {
  <S> byte[] isFoo() throws Exception;
  public static interface Nested {}

}
