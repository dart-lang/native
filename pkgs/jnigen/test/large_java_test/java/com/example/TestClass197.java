package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.isFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customEnum
public interface TestClass197<T extends Number>  extends DiamondLeft, DiamondRight {
  default <S, V> java.lang.Thread.State isFoo(java.lang.Thread.State p1, int p2) { return java.lang.Thread.State.NEW; }
  public enum NestedEnum { V1 }

}
