package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.string
public interface TestClass202<T extends Number>  extends DagA, DagD, DagE {
  default String isFoo(String p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
