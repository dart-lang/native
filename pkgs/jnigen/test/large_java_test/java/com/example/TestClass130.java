package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.object
public interface TestClass130<T>  extends DiamondLeft, DiamondRight {
  <S extends Number> Object[] getFoo(Object[] p1);
  public static record NestedRecord(int x) {}

}
