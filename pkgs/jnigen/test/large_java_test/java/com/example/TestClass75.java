package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.double_
public abstract class TestClass75<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public abstract <S, V> double[] getFoo(double[] p1, int p2);
  public enum NestedEnum { V1 }

}
