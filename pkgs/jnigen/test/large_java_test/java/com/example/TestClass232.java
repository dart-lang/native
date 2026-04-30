package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.none, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public interface TestClass232<T extends Number>  extends DagA, DagD, DagE {
  <S> NestedCustom<S, S>.Nested<S>[] getFoo(NestedCustom<S, S>.Nested<S>[] p1, int p2);
  public enum NestedEnum { V1 }

}
