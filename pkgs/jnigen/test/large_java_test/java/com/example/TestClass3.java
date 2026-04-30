package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.int_
public abstract class TestClass3<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public abstract <S extends Number> int[] setFoo(int[] p1, int p2);
  public static record NestedRecord(int x) {}

}
