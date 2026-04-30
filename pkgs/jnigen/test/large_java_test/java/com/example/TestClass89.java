// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.example;
import java.util.*;

// Generics: Generics.oneParam
// Inheritance: Inheritance.extendsGenericSpecialized
// IsArray: IsArray.no
// Member: Member.method
// MemberGenerics: MemberGenerics.none
// MemberModifier: MemberModifier.native
// MemberName: MemberName.setFoo
// NestedKind: NestedKind.none
// ParamCount: ParamCount.one
// TopLevelKind: TopLevelKind.interface
// TopLevelModifier: TopLevelModifier.none
// TypeKind: TypeKind.customRecord
public interface TestClass89<T>  extends List<String> {
  CustomRecord<T> setFoo(CustomRecord<T> p1);
}
