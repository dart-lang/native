package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.list
public abstract interface TestClass44<T extends Number>  extends DiamondLeft, DiamondRight {
  <S> List<S>[] myMethod(List<S>[] p1);
  public static record NestedRecord(int x) {}

}
