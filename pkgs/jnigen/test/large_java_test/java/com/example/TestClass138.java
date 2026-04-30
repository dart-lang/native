package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public interface TestClass138<T, U>  extends List {
  <S extends Number> Map.Entry<S, S>[] getFoo(Map.Entry<S, S>[] p1);
}
