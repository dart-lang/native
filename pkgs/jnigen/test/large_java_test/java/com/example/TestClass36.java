package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.native, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public interface TestClass36<T extends Number>  extends DagA, DagD, DagE {
  <S, V> Map<S, S> myMethod(Map<S, S> p1);
  public enum NestedEnum { V1 }

}
