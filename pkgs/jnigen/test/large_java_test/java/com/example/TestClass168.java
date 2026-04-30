package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.none, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.long_
public sealed class TestClass168<T, U>  {
  public long getFoo(long p1) { return 0; }
  public static record NestedRecord(int x) {}

  public static final class Sub<T, U> extends TestClass168<T, U> {}
}
