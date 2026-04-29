package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public abstract class TestClass180<T, U>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public abstract Set<T> getFoo(Set<T> p1);
  public static class Nested {}

}
