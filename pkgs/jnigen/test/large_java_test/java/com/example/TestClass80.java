package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.static_, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public class TestClass80  implements DiamondLeft, DiamondRight {
  public void run() {}
  public static <S extends Number> Set<S> getFoo() { return null; }
  public static interface Nested {}

}
