package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.typeParam
public interface TestClass249<T extends Number>  extends DiamondLeft, DiamondRight {
  <S extends Number> T[] getFoo(T[] p1, int p2);
  public static interface Nested {}

}
