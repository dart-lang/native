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
// MemberModifier: MemberModifier.synchronized
// MemberName: MemberName.getFoo
// NestedKind: NestedKind.enum_
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.double_
public interface TestClass191<T extends Number>  extends Runnable, Cloneable {
  <S> double[] getFoo(double[] p1, int p2);
  public enum NestedEnum { V1 }

}
