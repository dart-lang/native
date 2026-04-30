package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public interface TestClass153<T>  extends DagA, DagD, DagE {
  default <S, V> Set<S>[] getFoo(Set<S>[] p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
