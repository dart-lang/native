package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.typeParam
public abstract class TestClass100<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public abstract <S, V> T[] getFoo(T[] p1, int p2);
  public static interface Nested {}

}
