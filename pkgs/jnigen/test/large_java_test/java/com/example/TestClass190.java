package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.string
public interface TestClass190<T, U>  extends DagA, DagD, DagE {
  <S, V> String getFoo(String p1);
}
