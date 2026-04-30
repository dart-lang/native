package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.complexDag, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.native, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customRecord
public interface TestClass36  extends DagA, DagD, DagE {
  <S extends Number> CustomRecord<S> myMethod(CustomRecord<S> p1);
  public enum NestedEnum { V1 }

}
