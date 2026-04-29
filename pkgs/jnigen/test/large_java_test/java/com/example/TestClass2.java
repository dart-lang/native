package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.none, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public class TestClass2  implements DagA, DagD, DagE {
  public void run() {}
  public <S> Runnable[] isFoo(Runnable[] p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
