package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.int_
public interface TestClass108<T extends Number>  extends List {
  default <S extends Number> int[] getFoo() { return null; }
}
