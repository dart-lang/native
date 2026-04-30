// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.none
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.throws
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.boolean_
public interface TestClass200<T extends Number>  {
  <S> boolean[] getFoo(boolean[] p1, int p2) throws Exception;
  public enum NestedEnum { V1 }

}
