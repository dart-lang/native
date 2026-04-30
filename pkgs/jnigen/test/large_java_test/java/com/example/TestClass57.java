// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.twoParams
// Inheritance: Inheritance.implements_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.twoParams
// MemberModifier: MemberModifier.native
// MemberName: MemberName.any
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.string
public interface TestClass57<T, U>  extends Cloneable {
  <S, V> String myMethod(String p1);
  public enum NestedEnum { V1 }

}
