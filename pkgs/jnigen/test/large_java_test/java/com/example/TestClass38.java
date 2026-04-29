package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.setFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.object
public interface TestClass38<T, U>  extends DagA, DagD, DagE {
  <S, V> Object[] setFoo(Object[] p1);
  public static interface Nested {}

}
