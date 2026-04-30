package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.none, MemberName: MemberName.setFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customRecord
public class TestClass19<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public <S, V> CoreRecord setFoo() { return new CoreRecord(0, ""); }
  public static interface Nested {}

}
