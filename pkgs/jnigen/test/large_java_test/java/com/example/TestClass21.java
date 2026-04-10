package com.example;
import java.util.*;

// Generics: Generics.none, Inheritance: Inheritance.implements_, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.setFoo, NestedKind: NestedKind.class_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.enum_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.int_
public enum TestClass21  implements Runnable {
  VALUE1, VALUE2;
  public void run() {}
  public <S extends Number> int[] setFoo(int[] p1, int p2) { return null; }
  public static class Nested {}

}
