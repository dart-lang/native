package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.native, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.string
public sealed class TestClass173<T, U>  {
  public native String getFoo(String p1);
  public static record NestedRecord(int x) {}

  public static final class Sub<T, U> extends TestClass173<T, U> {}
}
