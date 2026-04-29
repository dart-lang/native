package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extendsGenericUnspecialized, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.byte_
public abstract class TestClass141<T, U>  extends ArrayList {
  public void run() {}
  public abstract <S extends Number> byte[] setFoo(byte[] p1, int p2);
  public static interface Nested {}

}
