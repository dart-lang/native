package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.double_
public abstract class TestClass118<T, U>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public abstract <S extends Number> double[] myMethod();
  public static record NestedRecord(int x) {}

}
