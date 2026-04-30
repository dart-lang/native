package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.final_, MemberName: MemberName.any, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.set
public sealed class TestClass130<T, U>  {
  public final Set<T> myMethod() { return null; }
  public static class Nested {}

  public static final class Sub<T, U> extends TestClass130<T, U> {}
}
