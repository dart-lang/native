package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public abstract interface TestClass231<T extends Number>  extends List {
  <S extends Number> Map.Entry<S, S>[] isFoo(Map.Entry<S, S>[] p1, int p2);
  public static record NestedRecord(int x) {}

}
