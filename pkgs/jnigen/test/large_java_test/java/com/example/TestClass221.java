// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.extends_
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.upperBound
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.setFoo
// NestedKind: NestedKind.none
// ParamCount: ParamCount.zero
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.byte_
public interface TestClass221<T extends Number>  extends Runnable {
  default <S extends Number> byte setFoo() { return 0; }
}
