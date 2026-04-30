package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.isFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.typeParam
public abstract class TestClass94<T extends Number>  extends ArrayList<String> {
  public void run() {}
  public abstract <S, V> T isFoo(T p1);
  public static interface Nested {}

}
