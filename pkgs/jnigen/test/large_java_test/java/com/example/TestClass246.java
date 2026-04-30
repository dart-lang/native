package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public abstract class TestClass246<T extends Number>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public abstract <S, V> Map<S, S> getFoo(Map<S, S> p1, int p2);
  public static record NestedRecord(int x) {}

}
