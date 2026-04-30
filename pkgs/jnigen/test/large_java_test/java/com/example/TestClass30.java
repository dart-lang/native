package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.throws, MemberName: MemberName.setFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customEnum
public interface TestClass30<T>  extends DiamondLeft, DiamondRight {
  <S extends Number> CustomEnum setFoo(CustomEnum p1, int p2) throws Exception;
}
