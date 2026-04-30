package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.any, NestedKind: NestedKind.innerClass, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public abstract class TestClass221<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public abstract <S> Map.Entry<S, S> myMethod(Map.Entry<S, S> p1, int p2);
  public class Nested {}

}
