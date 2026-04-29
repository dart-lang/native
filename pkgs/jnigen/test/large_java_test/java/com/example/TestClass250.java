package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extendsGenericSpecialized, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.setFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public class TestClass250<T extends Number>  extends ArrayList<String> {
  public void run() {}
  public <S extends Number> Map<S, S> setFoo(Map<S, S> p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
