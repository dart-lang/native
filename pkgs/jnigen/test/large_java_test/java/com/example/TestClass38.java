package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.native, MemberName: MemberName.isFoo, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.boolean_
public sealed class TestClass38<T, U>  {
  public native boolean isFoo();
  public static class Nested {}

  public static final class Sub<T, U> extends TestClass38<T, U> {}
}
