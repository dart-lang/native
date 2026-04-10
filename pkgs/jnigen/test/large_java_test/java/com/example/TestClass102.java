package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.native, MemberName: MemberName.setFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.typeParam
public interface TestClass102<T>  extends DagA, DagD, DagE {
  <S> T setFoo(T p1);
  public enum NestedEnum { V1 }

}
