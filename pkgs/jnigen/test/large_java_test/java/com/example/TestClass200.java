package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.static_, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.int_
public sealed class TestClass200<T extends Number>  {
  public static int myMethod(int p1) { return 0; }
  public enum NestedEnum { V1 }

  public static final class Sub<T extends Number> extends TestClass200<T> {}
}
