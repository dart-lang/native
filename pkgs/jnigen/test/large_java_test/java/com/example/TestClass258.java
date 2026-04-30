package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.static_, MemberName: MemberName.setFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.short_
public class TestClass258<T extends Number>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public static <S extends Number> short setFoo(short p1, int p2) { return 0; }
  public static record NestedRecord(int x) {}

}
