package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.class_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public abstract interface TestClass46<T>  extends DiamondLeft, DiamondRight {
  <S extends Number> long setFoo(long p1, int p2);
  public static class Nested {}

}
