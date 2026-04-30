// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.upperBound
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.yes
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.default_
// MemberName: MemberName.any
// NestedKind: NestedKind.none
// ParamCount: ParamCount.two
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customEnum
public interface TestClass127<T extends Number>  extends List<String> {
  default CustomEnum[] myMethod(CustomEnum[] p1, int p2) { return null; }
}
