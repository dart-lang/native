package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.list
public abstract class TestClass141<T>  extends ArrayList {
  public void run() {}
  public abstract <S extends Number> List<S>[] setFoo(List<S>[] p1, int p2);
  public static interface Nested {}

}
