package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.list
public interface TestClass140<T, U>  extends List {
  <S extends Number> List<S>[] getFoo(List<S>[] p1);
}
