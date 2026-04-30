package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.throws, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.double_
public interface TestClass77<T, U>  extends DagA, DagD, DagE {
  <S, V> double getFoo(double p1) throws Exception;
  public enum NestedEnum { V1 }

}
