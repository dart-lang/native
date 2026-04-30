package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.setFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.object
public interface TestClass133<T extends Number>  extends DiamondLeft, DiamondRight {
  default <S, V> Object[] setFoo(Object[] p1, int p2) { return null; }
}
