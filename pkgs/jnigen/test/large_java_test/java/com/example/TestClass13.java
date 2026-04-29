package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.isFoo, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.memberTypeParam
public final class TestClass13<T, U>  implements DagA, DagD, DagE {
  public void run() {}
  public synchronized <S extends Number> S isFoo() { return null; }
  public static class Nested {}

}
