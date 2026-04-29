package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.native, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public interface TestClass35<T extends Number>  extends DagA, DagD, DagE {
  Map<T, T> myMethod(Map<T, T> p1);
  public enum NestedEnum { V1 }

}
