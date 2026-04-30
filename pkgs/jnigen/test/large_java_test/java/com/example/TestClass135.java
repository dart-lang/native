package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.throws, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public interface TestClass135<T, U>  extends List {
  <S extends Number> NestedCustom<S, S>.Nested<S>[] getFoo(NestedCustom<S, S>.Nested<S>[] p1) throws Exception;
}
