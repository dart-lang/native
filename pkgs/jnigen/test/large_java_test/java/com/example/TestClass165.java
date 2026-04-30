// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.multipleImplements
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.oneParam
// MemberModifier: MemberModifier.abstract_
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.class_
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customEnum
public abstract class TestClass165<T extends Number>  implements Runnable, Cloneable {
  public void run() {}
  public abstract <S> CustomEnum[] getFoo();
  public enum NestedEnum { V1 }

}
