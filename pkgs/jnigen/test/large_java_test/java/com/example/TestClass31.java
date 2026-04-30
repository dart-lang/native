package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.setFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.object
public interface TestClass31  extends DiamondLeft, DiamondRight {
  <S extends Number> Object setFoo(Object p1, int p2);
}
