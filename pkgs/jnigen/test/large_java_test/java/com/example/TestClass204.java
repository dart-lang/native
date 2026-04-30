package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public interface TestClass204<T, U>  extends DagA, DagD, DagE {
  default <S, V> CustomInterface<S> isFoo(CustomInterface<S> p1, int p2) { return null; }
  public static interface Nested {}

}
