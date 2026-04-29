package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.native, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.string
public interface TestClass12<T>  extends DagA, DagD, DagE {
  <S extends Number> String[] getFoo();
  public static interface Nested {}

}
